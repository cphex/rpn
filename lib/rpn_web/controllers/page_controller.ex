defmodule RpnWeb.PageController do
  use RpnWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
