defmodule Mydia.Settings.QualityProfile do
  @moduledoc """
  Schema for quality profiles that define acceptable quality levels for media.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "quality_profiles" do
    field :name, :string
    field :upgrades_allowed, :boolean, default: true
    field :upgrade_until_quality, :string
    field :qualities, {:array, :string}
    field :rules, :map

    has_many :media_files, Mydia.Library.MediaFile

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a quality profile.
  """
  def changeset(quality_profile, attrs) do
    quality_profile
    |> cast(attrs, [:name, :upgrades_allowed, :upgrade_until_quality, :qualities, :rules])
    |> validate_required([:name, :qualities])
    |> validate_length(:qualities, min: 1)
    |> unique_constraint(:name)
  end
end
