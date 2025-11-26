defmodule Mydia.Settings.JsonAtomMapType do
  @moduledoc """
  Custom Ecto type for storing a map with atom keys as JSON in a text column.

  This type is designed for internal configuration data where atom keys are expected,
  such as quality profile settings. It differs from `JsonMapType` in that it atomizes
  keys when loading from the database.

  ## Usage
  In your schema:

      schema "my_table" do
        field :settings, Mydia.Settings.JsonAtomMapType
      end

  ## When to Use This Type

  Use `JsonAtomMapType` when:
  - The data is internal configuration created by code (not external user input)
  - The code expects atom keys (e.g., `Map.get(settings, :key_name)`)
  - Keys are from a known, limited set (to avoid atom table exhaustion)

  Use `JsonMapType` instead when:
  - The data comes from external sources (user input, external APIs)
  - Keys may be arbitrary or user-provided
  - Standard JSON string keys are expected

  ## Security Note

  This type uses `keys: :atoms` when decoding JSON, which creates atoms.
  Only use this for trusted, internal data. For external/untrusted data,
  use `JsonMapType` to avoid potential atom table exhaustion.
  """

  use Ecto.Type

  @doc """
  Returns the underlying database type (:string for text columns).
  """
  def type, do: :string

  @doc """
  Casts the given value to a map.

  Accepts:
  - Map with atom keys (returns as-is)
  - Map with string keys (converts to atom keys)
  - nil (returns empty map)
  """
  def cast(nil), do: {:ok, %{}}

  def cast(map) when is_map(map) do
    {:ok, atomize_keys(map)}
  end

  def cast(_), do: :error

  @doc """
  Loads data from the database (JSON string) and converts to a map with atom keys.
  """
  def load(nil), do: {:ok, %{}}
  def load(""), do: {:ok, %{}}

  def load(data) when is_binary(data) do
    case Jason.decode(data, keys: :atoms) do
      {:ok, map} when is_map(map) -> {:ok, map}
      {:ok, _} -> {:error, "Expected a JSON object"}
      {:error, _} -> {:error, "Invalid JSON"}
    end
  end

  # Handle case where data is already a map (some adapters may do this)
  def load(map) when is_map(map), do: {:ok, atomize_keys(map)}
  def load(_), do: :error

  @doc """
  Dumps a map to a JSON string for database storage.
  """
  def dump(nil), do: {:ok, "{}"}
  def dump(map) when map == %{}, do: {:ok, "{}"}

  def dump(map) when is_map(map) do
    {:ok, Jason.encode!(map)}
  end

  def dump(_), do: :error

  @doc """
  Compares two values for equality.
  """
  def equal?(map1, map2), do: map1 == map2

  @doc """
  Embeds the type as a parameter in queries.
  """
  def embed_as(_), do: :dump

  # Recursively convert string keys to atoms
  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn
      {key, value} when is_binary(key) -> {String.to_atom(key), atomize_keys(value)}
      {key, value} -> {key, atomize_keys(value)}
    end)
  end

  defp atomize_keys(list) when is_list(list) do
    Enum.map(list, &atomize_keys/1)
  end

  defp atomize_keys(value), do: value
end
