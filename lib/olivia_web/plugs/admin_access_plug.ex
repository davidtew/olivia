defmodule OliviaWeb.Plugs.AdminAccessPlug do
  @moduledoc """
  Blocks access to admin routes in production (when PHX_HOST is set).
  Returns 404 for admin routes on Fly deployment.
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if admin_blocked?() do
      conn
      |> put_status(:not_found)
      |> put_view(OliviaWeb.ErrorHTML)
      |> render("404.html")
      |> halt()
    else
      conn
    end
  end

  defp admin_blocked? do
    # Block admin in production (when PHX_HOST is set)
    # Allow access when ADMIN_ENABLED is explicitly set to "true"
    phx_host = System.get_env("PHX_HOST")
    admin_enabled = System.get_env("ADMIN_ENABLED")

    phx_host != nil and admin_enabled != "true"
  end
end
