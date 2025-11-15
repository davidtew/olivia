defmodule OliviaWeb.OliviaWeb.UserSessionHTML do
  use OliviaWeb, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:olivia, Olivia.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
