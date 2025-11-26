defmodule Mydia.Settings.JsonAtomMapTypeTest do
  use ExUnit.Case, async: true

  alias Mydia.Settings.JsonAtomMapType

  describe "type/0" do
    test "returns :string" do
      assert JsonAtomMapType.type() == :string
    end
  end

  describe "cast/1" do
    test "casts nil to empty map" do
      assert {:ok, %{}} = JsonAtomMapType.cast(nil)
    end

    test "casts empty map to empty map" do
      assert {:ok, %{}} = JsonAtomMapType.cast(%{})
    end

    test "casts map with atom keys" do
      map = %{key: "value", nested: %{inner: 123}}
      assert {:ok, ^map} = JsonAtomMapType.cast(map)
    end

    test "converts string keys to atom keys" do
      string_map = %{"key" => "value", "nested" => %{"inner" => 123}}
      expected = %{key: "value", nested: %{inner: 123}}
      assert {:ok, ^expected} = JsonAtomMapType.cast(string_map)
    end

    test "handles mixed keys" do
      mixed_map = %{"key" => "value", nested: %{"inner" => 123}}
      expected = %{key: "value", nested: %{inner: 123}}
      assert {:ok, ^expected} = JsonAtomMapType.cast(mixed_map)
    end

    test "handles lists in values" do
      map = %{"items" => [%{"name" => "a"}, %{"name" => "b"}]}
      expected = %{items: [%{name: "a"}, %{name: "b"}]}
      assert {:ok, ^expected} = JsonAtomMapType.cast(map)
    end

    test "returns error for non-map values" do
      assert :error = JsonAtomMapType.cast("string")
      assert :error = JsonAtomMapType.cast(123)
      assert :error = JsonAtomMapType.cast([1, 2, 3])
    end
  end

  describe "load/1" do
    test "loads nil as empty map" do
      assert {:ok, %{}} = JsonAtomMapType.load(nil)
    end

    test "loads empty string as empty map" do
      assert {:ok, %{}} = JsonAtomMapType.load("")
    end

    test "loads valid JSON with string keys, returns atom keys" do
      json = ~s({"key": "value", "count": 42})
      expected = %{key: "value", count: 42}
      assert {:ok, ^expected} = JsonAtomMapType.load(json)
    end

    test "loads nested JSON structures" do
      json = ~s({"outer": {"inner": "value", "list": [1, 2, 3]}})
      expected = %{outer: %{inner: "value", list: [1, 2, 3]}}
      assert {:ok, ^expected} = JsonAtomMapType.load(json)
    end

    test "loads JSON with array of objects" do
      json = ~s({"items": [{"name": "a"}, {"name": "b"}]})
      expected = %{items: [%{name: "a"}, %{name: "b"}]}
      assert {:ok, ^expected} = JsonAtomMapType.load(json)
    end

    test "handles already decoded map with string keys" do
      # Some adapters might return already decoded maps
      map = %{"key" => "value"}
      expected = %{key: "value"}
      assert {:ok, ^expected} = JsonAtomMapType.load(map)
    end

    test "handles already decoded map with atom keys" do
      map = %{key: "value"}
      assert {:ok, ^map} = JsonAtomMapType.load(map)
    end

    test "returns error for invalid JSON" do
      assert {:error, "Invalid JSON"} = JsonAtomMapType.load("not json")
    end

    test "returns error for JSON array" do
      assert {:error, "Expected a JSON object"} = JsonAtomMapType.load("[1, 2, 3]")
    end

    test "returns error for non-binary/map values" do
      assert :error = JsonAtomMapType.load(123)
    end
  end

  describe "dump/1" do
    test "dumps nil as empty JSON object" do
      assert {:ok, "{}"} = JsonAtomMapType.dump(nil)
    end

    test "dumps empty map as empty JSON object" do
      assert {:ok, "{}"} = JsonAtomMapType.dump(%{})
    end

    test "dumps map with atom keys to JSON" do
      map = %{key: "value", count: 42}
      assert {:ok, json} = JsonAtomMapType.dump(map)
      # Verify it's valid JSON by parsing it back
      assert {:ok, decoded} = Jason.decode(json)
      assert decoded == %{"key" => "value", "count" => 42}
    end

    test "dumps nested structures" do
      map = %{outer: %{inner: "value"}, list: [1, 2, 3]}
      assert {:ok, json} = JsonAtomMapType.dump(map)
      assert {:ok, decoded} = Jason.decode(json)
      assert decoded == %{"outer" => %{"inner" => "value"}, "list" => [1, 2, 3]}
    end

    test "returns error for non-map values" do
      assert :error = JsonAtomMapType.dump("string")
      assert :error = JsonAtomMapType.dump(123)
      assert :error = JsonAtomMapType.dump([1, 2, 3])
    end
  end

  describe "equal?/2" do
    test "returns true for equal maps" do
      map = %{key: "value"}
      assert JsonAtomMapType.equal?(map, map)
    end

    test "returns false for different maps" do
      refute JsonAtomMapType.equal?(%{a: 1}, %{b: 2})
    end

    test "returns true for empty maps" do
      assert JsonAtomMapType.equal?(%{}, %{})
    end
  end

  describe "embed_as/1" do
    test "returns :dump" do
      assert JsonAtomMapType.embed_as(:format) == :dump
    end
  end

  describe "round-trip" do
    test "preserves atom-keyed map through dump and load" do
      original = %{
        preferred_video_codecs: ["h265", "h264"],
        min_resolution: "720p",
        movie_max_size_mb: 15360,
        nested: %{inner: true}
      }

      assert {:ok, json} = JsonAtomMapType.dump(original)
      assert {:ok, loaded} = JsonAtomMapType.load(json)
      assert loaded == original
    end

    test "converts string-keyed input to atom-keyed output through cast" do
      input = %{
        "preferred_video_codecs" => ["h265", "h264"],
        "min_resolution" => "720p",
        "movie_max_size_mb" => 15360
      }

      expected = %{
        preferred_video_codecs: ["h265", "h264"],
        min_resolution: "720p",
        movie_max_size_mb: 15360
      }

      assert {:ok, result} = JsonAtomMapType.cast(input)
      assert result == expected
    end
  end
end
