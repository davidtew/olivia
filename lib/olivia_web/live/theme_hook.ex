defmodule OliviaWeb.ThemeHook do
  @moduledoc """
  LiveView hook to pass theme from session to socket assigns.
  """

  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    theme = session["theme"] || "original"
    {:cont, assign(socket, :theme, theme)}
  end
end
