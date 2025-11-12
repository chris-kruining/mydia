defmodule MetadataRelay.Cache.Adapter do
  @moduledoc """
  Behaviour for cache adapters.

  Defines the interface that cache implementations must follow,
  enabling pluggable cache backends (in-memory, Redis, etc.).
  """

  @doc """
  Gets a value from the cache.

  Returns `{:ok, value}` if found, `{:error, :not_found}` if not.
  """
  @callback get(key :: String.t()) ::
              {:ok, term()} | {:error, :not_found}

  @doc """
  Puts a value in the cache with the given TTL in milliseconds.

  Returns `:ok` on success.
  """
  @callback put(key :: String.t(), value :: term(), ttl :: non_neg_integer()) ::
              :ok | {:error, term()}

  @doc """
  Clears all entries from the cache.

  Returns `:ok` on success.
  """
  @callback clear() :: :ok | {:error, term()}

  @doc """
  Gets cache statistics.

  Returns a map with cache metrics. The specific metrics available
  depend on the adapter implementation.
  """
  @callback stats() :: map()
end
