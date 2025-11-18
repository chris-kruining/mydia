defmodule Mydia.Repo.Migrations.AddHealthCheckFieldsToCardigannDefinitions do
  use Ecto.Migration

  def change do
    alter table(:cardigann_definitions) do
      add :health_status, :string, default: "unknown"
      add :last_health_check_at, :utc_datetime
      add :last_successful_query_at, :utc_datetime
      add :consecutive_failures, :integer, default: 0
    end

    create index(:cardigann_definitions, [:health_status])
    create index(:cardigann_definitions, [:last_health_check_at])
  end
end
