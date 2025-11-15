defmodule Olivia.Emails.NewsletterEmail do
  import Swoosh.Email

  def build(to_email, subject, body_html) do
    from_email = Application.get_env(:olivia, :emails)[:from_email]
    from_name = Application.get_env(:olivia, :emails)[:from_name]

    new()
    |> to(to_email)
    |> from({from_name, from_email})
    |> subject(subject)
    |> html_body(body_html)
    |> text_body(strip_html(body_html))
  end

  defp strip_html(html) do
    html
    |> String.replace(~r/<[^>]*>/, "")
    |> String.replace(~r/&nbsp;/, " ")
    |> String.replace(~r/\n\s*\n/, "\n\n")
    |> String.trim()
  end
end
