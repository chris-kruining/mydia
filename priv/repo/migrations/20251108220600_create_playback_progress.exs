defmodule Mydia.Repo.Migrations.CreatePlaybackProgress do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TABLE playback_progress (
        id TEXT PRIMARY KEY NOT NULL,
        user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        media_item_id TEXT REFERENCES media_items(id) ON DELETE CASCADE,
        episode_id TEXT REFERENCES episodes(id) ON DELETE CASCADE,
        position_seconds INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        completion_percentage REAL NOT NULL,
        watched INTEGER NOT NULL DEFAULT 0,
        last_watched_at TEXT NOT NULL,
        inserted_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        CHECK(
          (media_item_id IS NOT NULL AND episode_id IS NULL) OR
          (media_item_id IS NULL AND episode_id IS NOT NULL)
        ),
        UNIQUE(user_id, media_item_id),
        UNIQUE(user_id, episode_id)
      )
      """,
      "DROP TABLE IF EXISTS playback_progress"
    )

    create index(:playback_progress, [:user_id])
    create index(:playback_progress, [:media_item_id])
    create index(:playback_progress, [:episode_id])
    create index(:playback_progress, [:last_watched_at])
  end
end
