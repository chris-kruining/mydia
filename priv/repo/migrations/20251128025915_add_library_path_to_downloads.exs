defmodule Mydia.Repo.Migrations.AddLibraryPathToDownloads do
  use Ecto.Migration

  @doc """
  Adds library_path_id to downloads table for specialized library downloads.

  This allows downloads for music, books, and adult content libraries to be
  tracked without requiring a media_item association. The library_path_id
  indicates where files should be imported after download completion.
  """
  def change do
    alter table(:downloads) do
      add :library_path_id, references(:library_paths, type: :binary_id, on_delete: :nilify_all)
    end

    create index(:downloads, [:library_path_id])
  end
end
