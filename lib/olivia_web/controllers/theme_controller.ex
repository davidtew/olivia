defmodule OliviaWeb.ThemeController do
  use OliviaWeb, :controller

  alias OliviaWeb.Plugs.ThemePlug

  @valid_themes ["original", "gallery", "cottage"]

  def set_theme(conn, %{"theme" => theme} = params) when theme in @valid_themes do
    redirect_to = params["redirect_to"] || "/"

    conn
    |> put_resp_header("cache-control", "no-cache, no-store, must-revalidate")
    |> put_resp_header("pragma", "no-cache")
    |> put_resp_header("expires", "0")
    |> ThemePlug.set_theme(theme)
    |> redirect(to: redirect_to)
  end

  def set_theme(conn, params) do
    # Invalid theme, redirect without changing
    redirect_to = params["redirect_to"] || "/"
    redirect(conn, to: redirect_to)
  end

  # Legacy toggle endpoint - kept for backwards compatibility
  def toggle(conn, params) do
    current_theme = conn.assigns[:theme] || "original"
    new_theme = if current_theme == "gallery", do: "original", else: "gallery"

    redirect_to = params["redirect_to"] || "/"

    conn
    |> ThemePlug.set_theme(new_theme)
    |> redirect(to: redirect_to)
  end

  # Legacy gallery endpoint - kept for backwards compatibility
  def set_gallery(conn, _params) do
    conn
    |> put_resp_header("cache-control", "no-cache, no-store, must-revalidate")
    |> put_resp_header("pragma", "no-cache")
    |> put_resp_header("expires", "0")
    |> ThemePlug.set_theme("gallery")
    |> redirect(to: "/")
  end
end
