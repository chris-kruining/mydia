defmodule Mydia.Repo.Migrations.BackfillFromEnvForLibraryPaths do
  use Ecto.Migration

  @doc """
  Backfill from_env=true for all existing library paths.

  All existing library paths were created from environment variables,
  so we mark them as such. This enables the startup sync to properly
  disable library paths that are removed from the env config.
  """
  def up do
    execute("UPDATE library_paths SET from_env = 1")
  end

  def down do
    execute("UPDATE library_paths SET from_env = 0")
  end
end
