defmodule Mydia.Repo.Migrations.AddFromEnvToLibraryPaths do
  use Ecto.Migration

  def change do
    alter table(:library_paths) do
      # Tracks if this library path was created from environment variables
      # Used to auto-disable paths when they're removed from env config
      add :from_env, :boolean, default: false, null: false
    end
  end
end
