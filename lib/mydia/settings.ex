defmodule Mydia.Settings do
  @moduledoc """
  The Settings context handles quality profiles and application configuration.
  """

  import Ecto.Query, warn: false
  alias Mydia.Repo
  alias Mydia.Settings.QualityProfile

  @doc """
  Returns the list of quality profiles.

  ## Options
    - `:preload` - List of associations to preload
  """
  def list_quality_profiles(opts \\ []) do
    QualityProfile
    |> maybe_preload(opts[:preload])
    |> order_by([q], asc: q.name)
    |> Repo.all()
  end

  @doc """
  Gets a single quality profile.

  ## Options
    - `:preload` - List of associations to preload

  Raises `Ecto.NoResultsError` if the quality profile does not exist.
  """
  def get_quality_profile!(id, opts \\ []) do
    QualityProfile
    |> maybe_preload(opts[:preload])
    |> Repo.get!(id)
  end

  @doc """
  Gets a quality profile by name.
  """
  def get_quality_profile_by_name(name, opts \\ []) do
    QualityProfile
    |> where([q], q.name == ^name)
    |> maybe_preload(opts[:preload])
    |> Repo.one()
  end

  @doc """
  Creates a quality profile.
  """
  def create_quality_profile(attrs \\ %{}) do
    %QualityProfile{}
    |> QualityProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a quality profile.
  """
  def update_quality_profile(%QualityProfile{} = quality_profile, attrs) do
    quality_profile
    |> QualityProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a quality profile.
  """
  def delete_quality_profile(%QualityProfile{} = quality_profile) do
    Repo.delete(quality_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quality profile changes.
  """
  def change_quality_profile(%QualityProfile{} = quality_profile, attrs \\ %{}) do
    QualityProfile.changeset(quality_profile, attrs)
  end

  ## Private Functions

  defp maybe_preload(query, nil), do: query
  defp maybe_preload(query, []), do: query
  defp maybe_preload(query, preloads), do: preload(query, ^preloads)
end
