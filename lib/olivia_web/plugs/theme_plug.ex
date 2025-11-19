defmodule OliviaWeb.Plugs.ThemePlug do
  @moduledoc """
  Plug to handle theme switching via cookies.
  Reads the theme preference from a cookie and assigns it to the connection.
  """

  import Plug.Conn

  @theme_cookie_key "olivia_theme"
  @default_theme "original"

  # Import theme IDs from shared component
  # This ensures theme validation stays in sync with the UI
  defp valid_themes do
    OliviaWeb.ThemeComponents.theme_ids()
  end

  def init(opts), do: opts

  def call(conn, _opts) do
    theme = get_theme_from_cookie(conn) || @default_theme

    conn
    |> assign(:theme, theme)
    |> Plug.Conn.put_session(:theme, theme)
  end

  defp get_theme_from_cookie(conn) do
    theme = conn.cookies[@theme_cookie_key]

    if theme in valid_themes() do
      theme
    else
      nil
    end
  end

  @doc """
  Sets the theme cookie.
  """
  def set_theme(conn, theme) do
    if theme in valid_themes() do
      put_resp_cookie(conn, @theme_cookie_key, theme,
        max_age: 365 * 24 * 60 * 60,
        http_only: true,
        same_site: "Lax"
      )
    else
      conn
    end
  end
end
