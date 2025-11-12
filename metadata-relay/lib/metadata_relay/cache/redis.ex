defmodule MetadataRelay.Cache.Redis do
  @moduledoc """
  Redis cache adapter using Redix.

  Provides persistent, distributed caching with support for:
  - Automatic key expiration with TTL
  - Persistence across service restarts
  - Horizontal scaling with shared cache
  - Graceful fallback if Redis is unavailable
  """

  use GenServer
  require Logger

  @behaviour MetadataRelay.Cache.Adapter

  @default_host "localhost"
  @default_port 6379
  @key_prefix "metadata_relay:"

  defmodule State do
    @moduledoc false
    defstruct [:conn, :hits, :misses, :connected]
  end

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl MetadataRelay.Cache.Adapter
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl MetadataRelay.Cache.Adapter
  def put(key, value, ttl) do
    GenServer.call(__MODULE__, {:put, key, value, ttl})
  end

  @impl MetadataRelay.Cache.Adapter
  def clear do
    GenServer.call(__MODULE__, :clear)
  end

  @impl MetadataRelay.Cache.Adapter
  def stats do
    GenServer.call(__MODULE__, :stats)
  end

  ## Server Callbacks

  @impl true
  def init(opts) do
    host = Keyword.get(opts, :host, @default_host)
    port = Keyword.get(opts, :port, @default_port)
    password = Keyword.get(opts, :password)

    redis_opts = [
      host: host,
      port: port,
      name: :metadata_relay_redis
    ]

    redis_opts = if password, do: Keyword.put(redis_opts, :password, password), else: redis_opts

    case Redix.start_link(redis_opts) do
      {:ok, conn} ->
        Logger.info("Redis cache adapter connected to #{host}:#{port}")

        state = %State{
          conn: conn,
          hits: 0,
          misses: 0,
          connected: true
        }

        {:ok, state}

      {:error, reason} ->
        Logger.error("Failed to connect to Redis: #{inspect(reason)}")

        state = %State{
          conn: nil,
          hits: 0,
          misses: 0,
          connected: false
        }

        {:ok, state}
    end
  end

  @impl true
  def handle_call({:get, _key}, _from, %State{connected: false} = state) do
    {:reply, {:error, :not_found}, %{state | misses: state.misses + 1}}
  end

  def handle_call({:get, key}, _from, %State{conn: conn} = state) do
    prefixed_key = prefix_key(key)

    case Redix.command(conn, ["GET", prefixed_key]) do
      {:ok, nil} ->
        Logger.debug("Cache miss: #{key}")
        {:reply, {:error, :not_found}, %{state | misses: state.misses + 1}}

      {:ok, binary} when is_binary(binary) ->
        try do
          value = :erlang.binary_to_term(binary, [:safe])
          Logger.debug("Cache hit: #{key}")
          {:reply, {:ok, value}, %{state | hits: state.hits + 1}}
        rescue
          error ->
            Logger.error("Failed to decode cached value: #{inspect(error)}")
            {:reply, {:error, :not_found}, %{state | misses: state.misses + 1}}
        end

      {:error, reason} ->
        Logger.error("Redis GET error: #{inspect(reason)}")
        {:reply, {:error, :not_found}, %{state | misses: state.misses + 1}}
    end
  end

  @impl true
  def handle_call({:put, _key, _value, _ttl}, _from, %State{connected: false} = state) do
    {:reply, {:error, :redis_unavailable}, state}
  end

  def handle_call({:put, key, value, ttl}, _from, %State{conn: conn} = state) do
    prefixed_key = prefix_key(key)
    ttl_seconds = div(ttl, 1000)

    try do
      binary = :erlang.term_to_binary(value)

      case Redix.command(conn, ["SETEX", prefixed_key, ttl_seconds, binary]) do
        {:ok, "OK"} ->
          Logger.debug("Cache put: #{key} (TTL: #{ttl}ms)")
          {:reply, :ok, state}

        {:error, reason} ->
          Logger.error("Redis SETEX error: #{inspect(reason)}")
          {:reply, {:error, reason}, state}
      end
    rescue
      error ->
        Logger.error("Failed to serialize value: #{inspect(error)}")
        {:reply, {:error, :serialization_failed}, state}
    end
  end

  @impl true
  def handle_call(:clear, _from, %State{connected: false} = state) do
    {:reply, {:error, :redis_unavailable}, state}
  end

  def handle_call(:clear, _from, %State{conn: conn} = state) do
    pattern = prefix_key("*")

    case scan_and_delete(conn, pattern) do
      {:ok, count} ->
        Logger.info("Cleared #{count} cache entries from Redis")
        {:reply, :ok, state}

      {:error, reason} ->
        Logger.error("Failed to clear cache: #{inspect(reason)}")
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:stats, _from, %State{connected: false} = state) do
    total = state.hits + state.misses
    hit_rate = if total > 0, do: Float.round(state.hits / total * 100, 1), else: 0.0

    stats = %{
      adapter: "redis",
      connected: false,
      hits: state.hits,
      misses: state.misses,
      total_requests: total,
      hit_rate_pct: hit_rate
    }

    {:reply, stats, state}
  end

  def handle_call(:stats, _from, %State{conn: conn} = state) do
    total = state.hits + state.misses
    hit_rate = if total > 0, do: Float.round(state.hits / total * 100, 1), else: 0.0

    # Get additional Redis stats
    redis_stats =
      case get_redis_info(conn) do
        {:ok, info} -> info
        {:error, _} -> %{}
      end

    stats =
      %{
        adapter: "redis",
        connected: true,
        hits: state.hits,
        misses: state.misses,
        total_requests: total,
        hit_rate_pct: hit_rate
      }
      |> Map.merge(redis_stats)

    {:reply, stats, state}
  end

  ## Private Functions

  defp prefix_key(key) do
    @key_prefix <> key
  end

  defp scan_and_delete(conn, pattern) do
    scan_and_delete(conn, pattern, "0", 0)
  end

  defp scan_and_delete(conn, pattern, cursor, count) do
    case Redix.command(conn, ["SCAN", cursor, "MATCH", pattern, "COUNT", "100"]) do
      {:ok, [next_cursor, keys]} ->
        deleted =
          if keys != [] do
            case Redix.command(conn, ["DEL" | keys]) do
              {:ok, n} -> n
              {:error, _} -> 0
            end
          else
            0
          end

        if next_cursor == "0" do
          {:ok, count + deleted}
        else
          scan_and_delete(conn, pattern, next_cursor, count + deleted)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_redis_info(conn) do
    case Redix.command(conn, ["INFO", "stats"]) do
      {:ok, info_string} ->
        info = parse_redis_info(info_string)
        {:ok, info}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_redis_info(info_string) do
    info_string
    |> String.split("\r\n")
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ":", parts: 2) do
        ["used_memory", value] ->
          case Integer.parse(value) do
            {bytes, _} ->
              Map.put(acc, :memory_bytes, bytes)
              |> Map.put(:memory_mb, Float.round(bytes / 1_024_000, 2))

            _ ->
              acc
          end

        _ ->
          acc
      end
    end)
  end
end
