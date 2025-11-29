defmodule Mydia.Repo.Migrations.AddDisabledToLibraryPaths do
  use Ecto.Migration

  def change do
    alter table(:library_paths) do
      # Controls whether the library path is hidden from the UI
      # Separate from `monitored` which controls scanning behavior
      add :disabled, :boolean, default: false, null: false
    end
  end
end
