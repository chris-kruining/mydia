defmodule Mydia.Repo.Migrations.AddImportedAtToDownloads do
  use Ecto.Migration

  def change do
    alter table(:downloads) do
      add :imported_at, :utc_datetime
    end

    create index(:downloads, [:imported_at])
  end
end
