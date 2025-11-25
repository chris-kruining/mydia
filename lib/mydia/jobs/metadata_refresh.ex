defmodule Mydia.Jobs.MetadataRefresh do
  @moduledoc """
  Background job for refreshing media metadata.

  This job:
  - Fetches the latest metadata from providers
  - Updates media items with fresh data
  - For TV shows, updates episode information
  - Can be triggered manually or scheduled
  """

  use Oban.Worker,
    queue: :media,
    max_attempts: 3

  require Logger
  alias Mydia.{Media, Metadata}
  alias Mydia.Metadata.Structs.SearchResult

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"media_item_id" => media_item_id} = args}) do
    start_time = System.monotonic_time(:millisecond)
    fetch_episodes = Map.get(args, "fetch_episodes", true)
    config = Metadata.default_relay_config()

    Logger.info("Starting metadata refresh", media_item_id: media_item_id)

    result =
      case Media.get_media_item!(media_item_id) do
        nil ->
          Logger.error("Media item not found", media_item_id: media_item_id)
          {:error, :not_found}

        media_item ->
          refresh_media_item(media_item, config, fetch_episodes)
      end

    duration = System.monotonic_time(:millisecond) - start_time

    case result do
      :ok ->
        Logger.info("Metadata refresh completed",
          duration_ms: duration,
          media_item_id: media_item_id
        )

        :ok

      {:error, reason} ->
        Logger.error("Metadata refresh failed",
          error: inspect(reason),
          duration_ms: duration,
          media_item_id: media_item_id
        )

        {:error, reason}
    end
  rescue
    _e in Ecto.NoResultsError ->
      Logger.error("Media item not found", media_item_id: media_item_id)
      {:error, :not_found}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"refresh_all" => true}}) do
    start_time = System.monotonic_time(:millisecond)
    Logger.info("Starting metadata refresh for all media items")

    result = refresh_all_media()
    duration = System.monotonic_time(:millisecond) - start_time

    case result do
      {:ok, count} ->
        Logger.info("Metadata refresh all completed",
          duration_ms: duration,
          items_processed: count
        )

        :ok
    end
  end

  ## Private Functions

  defp refresh_media_item(media_item, config, fetch_episodes) do
    # Try to get tmdb_id from media_item or extract from stored metadata
    tmdb_id = get_or_extract_tmdb_id(media_item)
    media_type = parse_media_type(media_item.type)

    # If no TMDB ID, try to recover it by searching by title
    tmdb_id =
      if tmdb_id do
        tmdb_id
      else
        Logger.info("No TMDB ID found, attempting to recover by title search",
          media_item_id: media_item.id,
          title: media_item.title
        )

        case search_for_tmdb_id(media_item, media_type, config) do
          {:ok, found_id} ->
            Logger.info("Successfully recovered TMDB ID via title search",
              media_item_id: media_item.id,
              title: media_item.title,
              tmdb_id: found_id
            )

            found_id

          {:error, reason} ->
            Logger.warning("Failed to recover TMDB ID via title search",
              media_item_id: media_item.id,
              title: media_item.title,
              reason: reason
            )

            nil
        end
      end

    if tmdb_id do
      Logger.info("Refreshing metadata",
        media_item_id: media_item.id,
        title: media_item.title,
        tmdb_id: tmdb_id
      )

      case fetch_updated_metadata(tmdb_id, media_type, config) do
        {:ok, metadata} ->
          attrs = build_update_attrs(metadata, media_type)

          case Media.update_media_item(media_item, attrs) do
            {:ok, updated_item} ->
              Logger.info("Successfully refreshed metadata",
                media_item_id: updated_item.id,
                title: updated_item.title
              )

              # For TV shows, optionally refresh episodes
              if media_type == :tv_show and fetch_episodes do
                Media.refresh_episodes_for_tv_show(updated_item)
              end

              :ok

            {:error, changeset} ->
              Logger.error("Failed to update media item",
                media_item_id: media_item.id,
                errors: inspect(changeset.errors)
              )

              {:error, :update_failed}
          end

        {:error, reason} ->
          Logger.error("Failed to fetch updated metadata",
            media_item_id: media_item.id,
            tmdb_id: tmdb_id,
            reason: reason
          )

          {:error, reason}
      end
    else
      Logger.warning("Media item has no TMDB ID and could not recover via title search",
        media_item_id: media_item.id
      )

      {:error, :no_tmdb_id}
    end
  end

  defp refresh_all_media do
    media_items = Media.list_media_items(monitored: true)

    Logger.info("Refreshing metadata for #{length(media_items)} media items")

    results =
      Enum.map(media_items, fn media_item ->
        config = Metadata.default_relay_config()
        refresh_media_item(media_item, config, false)
      end)

    successful = Enum.count(results, &(&1 == :ok))
    failed = Enum.count(results, &match?({:error, _}, &1))

    Logger.info("Metadata refresh completed",
      total: length(results),
      successful: successful,
      failed: failed
    )

    {:ok, successful}
  end

  defp parse_media_type("movie"), do: :movie
  defp parse_media_type("tv_show"), do: :tv_show
  defp parse_media_type(_), do: :movie

  defp fetch_updated_metadata(tmdb_id, media_type, config) do
    fetch_opts = [
      media_type: media_type,
      append_to_response: ["credits", "images", "videos", "keywords"]
    ]

    Metadata.fetch_by_id(config, to_string(tmdb_id), fetch_opts)
  end

  defp build_update_attrs(metadata, _media_type) do
    %{
      title: metadata.title,
      original_title: metadata.original_title,
      year: extract_year(metadata),
      tmdb_id: metadata.id,
      imdb_id: metadata.imdb_id,
      metadata: metadata
    }
  end

  defp get_or_extract_tmdb_id(media_item) do
    cond do
      # If tmdb_id is already set, use it
      media_item.tmdb_id ->
        media_item.tmdb_id

      # Try to extract from metadata["id"] (new format after fix - string key)
      media_item.metadata && media_item.metadata["id"] ->
        case media_item.metadata["id"] do
          id when is_integer(id) ->
            id

          id when is_binary(id) ->
            case Integer.parse(id) do
              {parsed_id, ""} -> parsed_id
              _ -> nil
            end

          _ ->
            nil
        end

      # Try to extract from metadata["provider_id"] (old format - string key)
      media_item.metadata && media_item.metadata["provider_id"] ->
        case Integer.parse(media_item.metadata["provider_id"]) do
          {id, ""} -> id
          _ -> nil
        end

      # No tmdb_id available
      true ->
        nil
    end
  end

  defp extract_year(metadata) do
    cond do
      metadata.release_date ->
        metadata.release_date.year

      metadata.first_air_date ->
        metadata.first_air_date.year

      true ->
        nil
    end
  end

  # Search for TMDB ID by title when it's missing from the media item
  defp search_for_tmdb_id(media_item, media_type, config) do
    search_opts = build_search_opts(media_item, media_type)

    case Metadata.search(config, media_item.title, search_opts) do
      {:ok, []} ->
        # Try without year if we got no results
        if media_item.year do
          retry_opts = Keyword.delete(search_opts, :year)

          case Metadata.search(config, media_item.title, retry_opts) do
            {:ok, results} when results != [] ->
              select_best_match(results, media_item)

            _ ->
              {:error, :no_matches_found}
          end
        else
          {:error, :no_matches_found}
        end

      {:ok, results} ->
        select_best_match(results, media_item)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_search_opts(media_item, media_type) do
    opts = [media_type: media_type]

    if media_item.year do
      Keyword.put(opts, :year, media_item.year)
    else
      opts
    end
  end

  # Select the best match from search results based on title similarity and year
  defp select_best_match(results, media_item) do
    scored_results =
      Enum.map(results, fn result ->
        score = calculate_match_score(result, media_item)
        {result, score}
      end)

    case Enum.max_by(scored_results, fn {_result, score} -> score end, fn -> nil end) do
      {%SearchResult{provider_id: provider_id}, score} when score >= 0.5 ->
        case Integer.parse(provider_id) do
          {id, ""} -> {:ok, id}
          _ -> {:error, :invalid_provider_id}
        end

      _ ->
        {:error, :no_confident_match}
    end
  end

  defp calculate_match_score(result, media_item) do
    base_score = 0.5
    title_sim = title_similarity(result.title, media_item.title)

    score =
      base_score
      |> add_score(title_sim, 0.25)
      |> add_score(year_match?(result.year, media_item.year), 0.15)
      |> add_score(exact_title_match?(result.title, media_item.title), 0.15)
      |> add_score(title_derivative_penalty(result.title, media_item.title), 1.0)

    min(score, 1.0)
  end

  defp add_score(current, true, amount), do: current + amount
  defp add_score(current, score, amount) when is_float(score), do: current + score * amount
  defp add_score(current, _false_or_nil, _amount), do: current

  defp title_similarity(title1, title2) when is_binary(title1) and is_binary(title2) do
    norm1 = normalize_title(title1)
    norm2 = normalize_title(title2)

    cond do
      norm1 == norm2 -> 1.0
      String.contains?(norm1, norm2) or String.contains?(norm2, norm1) -> 0.8
      true -> String.jaro_distance(norm1, norm2)
    end
  end

  defp title_similarity(_title1, _title2), do: 0.0

  defp normalize_title(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^\w\s]/, "")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp exact_title_match?(result_title, search_title)
       when is_binary(result_title) and is_binary(search_title) do
    normalize_title(result_title) == normalize_title(search_title)
  end

  defp exact_title_match?(_result_title, _search_title), do: false

  defp title_derivative_penalty(result_title, search_title)
       when is_binary(result_title) and is_binary(search_title) do
    norm_result = String.downcase(result_title) |> String.trim()
    norm_search = String.downcase(search_title) |> String.trim()

    if norm_result != norm_search and String.contains?(norm_result, norm_search) do
      search_len = String.length(norm_search)
      result_len = String.length(norm_result)
      extra_ratio = (result_len - search_len) / result_len
      -extra_ratio * 0.15
    else
      0.0
    end
  end

  defp title_derivative_penalty(_result_title, _search_title), do: 0.0

  defp year_match?(result_year, nil), do: result_year != nil
  defp year_match?(nil, _media_year), do: false

  defp year_match?(result_year, media_year) when is_integer(result_year) do
    abs(result_year - media_year) <= 1
  end

  defp year_match?(_result_year, _media_year), do: false
end
