defmodule OliviaWeb.PageController do
  use OliviaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
