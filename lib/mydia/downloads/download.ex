defmodule Mydia.Downloads.Download do
  @moduledoc """
  Schema for download queue items.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @status_values ~w(pending downloading completed failed cancelled)

  schema "downloads" do
    field :status, :string
    field :indexer, :string
    field :title, :string
    field :download_url, :string
    field :download_client, :string
    field :download_client_id, :string
    field :progress, :float
    field :estimated_completion, :utc_datetime
    field :completed_at, :utc_datetime
    field :error_message, :string
    field :metadata, :map

    belongs_to :media_item, Mydia.Media.MediaItem
    belongs_to :episode, Mydia.Media.Episode

    timestamps(type: :utc_datetime, updated_at: :updated_at)
  end

  @doc """
  Changeset for creating or updating a download.
  """
  def changeset(download, attrs) do
    download
    |> cast(attrs, [
      :media_item_id,
      :episode_id,
      :status,
      :indexer,
      :title,
      :download_url,
      :download_client,
      :download_client_id,
      :progress,
      :estimated_completion,
      :completed_at,
      :error_message,
      :metadata
    ])
    |> validate_required([:status, :title])
    |> validate_inclusion(:status, @status_values)
    |> validate_number(:progress, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> foreign_key_constraint(:media_item_id)
    |> foreign_key_constraint(:episode_id)
  end

  @doc """
  Returns the list of valid status values.
  """
  def valid_statuses, do: @status_values
end
