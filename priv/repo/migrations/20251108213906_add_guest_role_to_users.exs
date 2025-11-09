defmodule Mydia.Repo.Migrations.AddGuestRoleToUsers do
  use Ecto.Migration

  def up do
    # SQLite doesn't support dropping CHECK constraints, so we need to recreate the table
    # Create a temporary table with the new constraint
    execute("""
    CREATE TABLE users_temp (
      id TEXT PRIMARY KEY NOT NULL,
      username TEXT UNIQUE,
      email TEXT UNIQUE,
      password_hash TEXT,
      oidc_sub TEXT UNIQUE,
      oidc_issuer TEXT,
      role TEXT NOT NULL DEFAULT 'user' CHECK(role IN ('admin', 'user', 'readonly', 'guest')),
      display_name TEXT,
      avatar_url TEXT,
      last_login_at TEXT,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """)

    # Copy all data from old table to new table
    execute("""
    INSERT INTO users_temp
    SELECT * FROM users
    """)

    # Drop the old table
    execute("DROP TABLE users")

    # Rename temp table to users
    execute("ALTER TABLE users_temp RENAME TO users")

    # Recreate the index
    create index(:users, [:oidc_sub, :oidc_issuer])
  end

  def down do
    # Recreate the table without 'guest' role
    execute("""
    CREATE TABLE users_temp (
      id TEXT PRIMARY KEY NOT NULL,
      username TEXT UNIQUE,
      email TEXT UNIQUE,
      password_hash TEXT,
      oidc_sub TEXT UNIQUE,
      oidc_issuer TEXT,
      role TEXT NOT NULL DEFAULT 'user' CHECK(role IN ('admin', 'user', 'readonly')),
      display_name TEXT,
      avatar_url TEXT,
      last_login_at TEXT,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    """)

    # Copy data, excluding any users with 'guest' role
    execute("""
    INSERT INTO users_temp
    SELECT * FROM users WHERE role != 'guest'
    """)

    # Drop the old table
    execute("DROP TABLE users")

    # Rename temp table to users
    execute("ALTER TABLE users_temp RENAME TO users")

    # Recreate the index
    create index(:users, [:oidc_sub, :oidc_issuer])
  end
end
