defmodule MetadataRelay.Repo do
  use Ecto.Repo,
    otp_app: :metadata_relay,
    adapter: Ecto.Adapters.SQLite3
end
