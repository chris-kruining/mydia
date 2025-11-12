defmodule Mydia.Repo.Migrations.PopulateEpisodeAirDatesFromMetadata do
  use Ecto.Migration
  import Ecto.Query
  alias Mydia.Repo

  def up do
    # For SQLite, we'll use SQL to extract JSON and update the air_date column
    # This populates air_date from the metadata JSON field for all episodes
    execute """
    UPDATE episodes
    SET air_date = json_extract(metadata, '$.air_date')
    WHERE air_date IS NULL
      AND json_extract(metadata, '$.air_date') IS NOT NULL
      AND json_extract(metadata, '$.air_date') != ''
    """
  end

  def down do
    # We don't want to clear air_dates on rollback since they should have been
    # populated correctly. This is a data fix migration.
    :ok
  end
end
