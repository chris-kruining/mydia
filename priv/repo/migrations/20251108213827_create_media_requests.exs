defmodule Mydia.Repo.Migrations.CreateMediaRequests do
  use Ecto.Migration

  def change do
    create table(:media_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :media_type, :string, null: false
      add :title, :string, null: false
      add :original_title, :string
      add :year, :integer
      add :tmdb_id, :integer
      add :imdb_id, :string
      add :status, :string, null: false, default: "pending"
      add :requester_notes, :text
      add :admin_notes, :text
      add :rejection_reason, :text
      add :approved_at, :utc_datetime
      add :rejected_at, :utc_datetime

      add :requester_id, references(:users, type: :binary_id, on_delete: :restrict), null: false
      add :approved_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :media_item_id, references(:media_items, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:media_requests, [:requester_id])
    create index(:media_requests, [:status])
    create index(:media_requests, [:tmdb_id])
    create index(:media_requests, [:media_type])
    create index(:media_requests, [:approved_by_id])
    create index(:media_requests, [:media_item_id])

    # Composite index for duplicate detection
    create index(:media_requests, [:tmdb_id, :status])
    create index(:media_requests, [:imdb_id, :status])

    # Add CHECK constraint for valid status values (SQLite)
    execute(
      """
      CREATE TRIGGER validate_media_request_status_insert
      BEFORE INSERT ON media_requests
      FOR EACH ROW
      WHEN NEW.status NOT IN ('pending', 'approved', 'rejected')
      BEGIN
        SELECT RAISE(ABORT, 'Invalid status value');
      END;
      """,
      "DROP TRIGGER IF EXISTS validate_media_request_status_insert;"
    )

    execute(
      """
      CREATE TRIGGER validate_media_request_status_update
      BEFORE UPDATE ON media_requests
      FOR EACH ROW
      WHEN NEW.status NOT IN ('pending', 'approved', 'rejected')
      BEGIN
        SELECT RAISE(ABORT, 'Invalid status value');
      END;
      """,
      "DROP TRIGGER IF EXISTS validate_media_request_status_update;"
    )

    # Add CHECK constraint for valid media_type values (SQLite)
    execute(
      """
      CREATE TRIGGER validate_media_type_insert
      BEFORE INSERT ON media_requests
      FOR EACH ROW
      WHEN NEW.media_type NOT IN ('movie', 'tv_show')
      BEGIN
        SELECT RAISE(ABORT, 'Invalid media_type value');
      END;
      """,
      "DROP TRIGGER IF EXISTS validate_media_type_insert;"
    )

    execute(
      """
      CREATE TRIGGER validate_media_type_update
      BEFORE UPDATE ON media_requests
      FOR EACH ROW
      WHEN NEW.media_type NOT IN ('movie', 'tv_show')
      BEGIN
        SELECT RAISE(ABORT, 'Invalid media_type value');
      END;
      """,
      "DROP TRIGGER IF EXISTS validate_media_type_update;"
    )
  end
end
