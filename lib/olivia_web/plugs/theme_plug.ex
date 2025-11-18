defmodule OliviaWeb.Plugs.ThemePlug do
  @moduledoc """
  Plug to handle theme switching via cookies.
  Reads the theme preference from a cookie and assigns it to the connection.
  """

  import Plug.Conn

  @theme_cookie_key "olivia_theme"
  @default_theme "original"
  @valid_themes ["original", "gallery", "cottage"]

  def init(opts), do: opts

  def call(conn, _opts) do
    theme = get_theme_from_cookie(conn) || @default_theme

    conn
    |> assign(:theme, theme)
    |> Plug.Conn.put_session(:theme, theme)
  end

  defp get_theme_from_cookie(conn) do
    case conn.cookies[@theme_cookie_key] do
      theme when theme in @valid_themes -> theme
      _ -> nil
    end
  end

  @doc """
  Sets the theme cookie.
  """
  def set_theme(conn, theme) when theme in @valid_themes do
    put_resp_cookie(conn, @theme_cookie_key, theme,
      max_age: 365 * 24 * 60 * 60,
      http_only: true,
      same_site: "Lax"
    )
  end

  def set_theme(conn, _invalid_theme), do: conn
end
