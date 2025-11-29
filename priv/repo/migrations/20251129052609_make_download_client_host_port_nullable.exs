defmodule Mydia.Repo.Migrations.MakeDownloadClientHostPortNullable do
  @moduledoc """
  Make host and port nullable for download client configs.

  Blackhole clients use folder paths from connection_settings instead of
  host/port, so these fields should be optional.

  SQLite doesn't support ALTER COLUMN, so we recreate the table.
  """
  use Ecto.Migration

  def up do
    # SQLite doesn't support ALTER COLUMN, so we need to recreate the table
    execute """
    CREATE TABLE download_client_configs_new (
      id BLOB PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      enabled INTEGER DEFAULT 1,
      priority INTEGER DEFAULT 1,
      host TEXT,
      port INTEGER,
      use_ssl INTEGER DEFAULT 0,
      url_base TEXT,
      username TEXT,
      password TEXT,
      api_key TEXT,
      category TEXT,
      download_directory TEXT,
      connection_settings TEXT,
      updated_by_id BLOB REFERENCES users(id) ON DELETE SET NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO download_client_configs_new
    SELECT * FROM download_client_configs
    """

    execute "DROP TABLE download_client_configs"

    execute "ALTER TABLE download_client_configs_new RENAME TO download_client_configs"

    # Recreate indexes
    create unique_index(:download_client_configs, [:name])
    create index(:download_client_configs, [:enabled])
    create index(:download_client_configs, [:priority])
    create index(:download_client_configs, [:type])
  end

  def down do
    # Restore NOT NULL constraints (may fail if null values exist)
    execute """
    CREATE TABLE download_client_configs_new (
      id BLOB PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      enabled INTEGER DEFAULT 1,
      priority INTEGER DEFAULT 1,
      host TEXT NOT NULL,
      port INTEGER NOT NULL,
      use_ssl INTEGER DEFAULT 0,
      url_base TEXT,
      username TEXT,
      password TEXT,
      api_key TEXT,
      category TEXT,
      download_directory TEXT,
      connection_settings TEXT,
      updated_by_id BLOB REFERENCES users(id) ON DELETE SET NULL,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """

    execute """
    INSERT INTO download_client_configs_new
    SELECT * FROM download_client_configs
    """

    execute "DROP TABLE download_client_configs"

    execute "ALTER TABLE download_client_configs_new RENAME TO download_client_configs"

    create unique_index(:download_client_configs, [:name])
    create index(:download_client_configs, [:enabled])
    create index(:download_client_configs, [:priority])
    create index(:download_client_configs, [:type])
  end
end
