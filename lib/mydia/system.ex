defmodule Mydia.System do
  @moduledoc """
  System information helpers for application version, environment, etc.
  """

  # Capture the environment at compile time so it's available in releases
  @env Mix.env()

  @doc """
  Get the application version from mix.exs.
  """
  def app_version do
    case Application.spec(:mydia, :vsn) do
      nil -> "unknown"
      vsn -> to_string(vsn)
    end
  end

  @doc """
  Check if running in development mode.
  """
  def dev_mode? do
    @env == :dev
  end
end
