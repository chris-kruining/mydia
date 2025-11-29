defmodule Mydia.Indexers.CardigannOverridesTest do
  use ExUnit.Case, async: true

  alias Mydia.Indexers.CardigannOverrides

  describe "list_overrides/0" do
    test "returns registered overrides" do
      overrides = CardigannOverrides.list_overrides()
      assert is_map(overrides)
      assert Map.has_key?(overrides, "1337x")
    end
  end

  describe "has_override?/1" do
    test "returns true for registered indexers" do
      assert CardigannOverrides.has_override?("1337x")
    end

    test "returns false for unregistered indexers" do
      refute CardigannOverrides.has_override?("unknown-indexer")
    end
  end

  describe "get_override/1" do
    test "returns override metadata for registered indexers" do
      override = CardigannOverrides.get_override("1337x")
      assert override.description =~ "sort-search"
      assert is_function(override.patch, 1)
    end

    test "returns nil for unregistered indexers" do
      assert CardigannOverrides.get_override("unknown-indexer") == nil
    end
  end

  describe "apply_overrides/2" do
    test "returns unmodified data for indexers without overrides" do
      yaml_data = %{"id" => "unknown", "search" => %{"paths" => ["/test/"]}}
      assert {:ok, ^yaml_data} = CardigannOverrides.apply_overrides("unknown", yaml_data)
    end

    test "returns patched data with :patched indicator for registered indexers" do
      yaml_data = %{
        "id" => "1337x",
        "search" => %{
          "paths" => [
            %{"path" => "sort-search/{{ .Keywords }}/time/desc/1/"}
          ]
        }
      }

      assert {:ok, patched_data, :patched} =
               CardigannOverrides.apply_overrides("1337x", yaml_data)

      assert patched_data["search"]["paths"] != yaml_data["search"]["paths"]
    end
  end

  describe "patch_1337x/1" do
    test "replaces sort-search paths with search paths" do
      yaml_data = %{
        "id" => "1337x",
        "search" => %{
          "paths" => [
            %{
              "path" =>
                "{{ if or .Query.Album .Query.Artist .Keywords }}sort-search{{ else }}cat/Movies{{ end }}/{{ .Keywords }}/{{ .Config.sort }}/{{ .Config.type }}/1/"
            }
          ]
        }
      }

      patched = CardigannOverrides.patch_1337x(yaml_data)
      paths = patched["search"]["paths"]

      # Should have 4 paths (pages 1-4)
      assert length(paths) == 4

      # First path should be for page 1
      first_path = hd(paths)["path"]
      assert first_path =~ "search/"
      refute first_path =~ "sort-search"
      assert first_path =~ "/1/"
    end

    test "patched paths use working URL format" do
      yaml_data = %{"id" => "1337x", "search" => %{"paths" => []}}
      patched = CardigannOverrides.patch_1337x(yaml_data)

      for path_entry <- patched["search"]["paths"] do
        path = path_entry["path"]
        # When keywords are provided, should use /search/keywords/page/
        assert path =~ "search/{{ or .Query.Album .Query.Artist .Keywords }}/"
        # Should NOT use sort-search
        refute path =~ "sort-search"
      end
    end

    test "patched paths preserve category browsing for empty searches" do
      yaml_data = %{"id" => "1337x", "search" => %{"paths" => []}}
      patched = CardigannOverrides.patch_1337x(yaml_data)

      # When no keywords, should fall back to category browsing
      first_path = hd(patched["search"]["paths"])["path"]
      assert first_path =~ "cat/Movies"
    end
  end
end
