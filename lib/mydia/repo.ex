defmodule Mydia.Repo do
  use Ecto.Repo,
    otp_app: :mydia,
    adapter: Ecto.Adapters.SQLite3
end
