defmodule MydiaWeb.PageController do
  use MydiaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
