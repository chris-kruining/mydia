defmodule Mydia.Repo.Migrations.CreateCardigannDefinitions do
  use Ecto.Migration

  def change do
    # Cardigann definitions table: stores indexer definitions from Prowlarr/Cardigann
    # Tracks available indexers and their configuration
    execute(
      """
      CREATE TABLE cardigann_definitions (
        id TEXT PRIMARY KEY NOT NULL,
        indexer_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        language TEXT,
        type TEXT NOT NULL,
        encoding TEXT,
        links TEXT NOT NULL,
        capabilities TEXT NOT NULL,
        definition TEXT NOT NULL,
        schema_version TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 0 CHECK(enabled IN (0, 1)),
        config TEXT,
        last_synced_at TEXT,
        inserted_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      """,
      "DROP TABLE IF EXISTS cardigann_definitions"
    )

    create index(:cardigann_definitions, [:indexer_id], unique: true)
    create index(:cardigann_definitions, [:enabled])
    create index(:cardigann_definitions, [:type])

    # Cardigann search sessions table: manages login sessions for private indexers
    # Stores encrypted cookies and session state
    execute(
      """
      CREATE TABLE cardigann_search_sessions (
        id TEXT PRIMARY KEY NOT NULL,
        cardigann_definition_id TEXT NOT NULL REFERENCES cardigann_definitions(id) ON DELETE CASCADE,
        cookies TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        inserted_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      """,
      "DROP TABLE IF EXISTS cardigann_search_sessions"
    )

    create index(:cardigann_search_sessions, [:cardigann_definition_id])
    create index(:cardigann_search_sessions, [:expires_at])
  end
end
