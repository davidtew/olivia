defmodule Olivia.Emails.EnquiryEmail do
  import Swoosh.Email

  def new_enquiry_notification(enquiry, admin_email) do
    from_email = Application.get_env(:olivia, :emails)[:from_email]
    from_name = Application.get_env(:olivia, :emails)[:from_name]

    type_label = enquiry_type_label(enquiry.type)

    new()
    |> to(admin_email)
    |> from({from_name, from_email})
    |> reply_to(enquiry.email)
    |> subject("New #{type_label} Enquiry from #{enquiry.name}")
    |> html_body(build_html_body(enquiry, type_label))
    |> text_body(build_text_body(enquiry, type_label))
  end

  defp build_html_body(enquiry, type_label) do
    """
    <html>
      <body style="font-family: sans-serif; line-height: 1.6; color: #333;">
        <h2 style="color: #111;">New #{type_label} Enquiry</h2>

        <p><strong>From:</strong> #{enquiry.name}</p>
        <p><strong>Email:</strong> <a href="mailto:#{enquiry.email}">#{enquiry.email}</a></p>
        <p><strong>Type:</strong> #{type_label}</p>
        <p><strong>Date:</strong> #{Calendar.strftime(enquiry.inserted_at, "%d %B %Y at %H:%M")}</p>

        <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;" />

        <h3 style="color: #111;">Message:</h3>
        <div style="background: #f9f9f9; padding: 15px; border-left: 3px solid #666;">
          #{String.replace(enquiry.message, "\n", "<br>")}
        </div>

        <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;" />

        <p style="font-size: 12px; color: #666;">
          You can reply directly to this email to respond to #{enquiry.name}.
        </p>
      </body>
    </html>
    """
  end

  defp build_text_body(enquiry, type_label) do
    """
    New #{type_label} Enquiry

    From: #{enquiry.name}
    Email: #{enquiry.email}
    Type: #{type_label}
    Date: #{Calendar.strftime(enquiry.inserted_at, "%d %B %Y at %H:%M")}

    ---

    Message:

    #{enquiry.message}

    ---

    You can reply directly to this email to respond to #{enquiry.name}.
    """
  end

  defp enquiry_type_label("artwork"), do: "Artwork Purchase"
  defp enquiry_type_label("commission"), do: "Commission"
  defp enquiry_type_label("project"), do: "Project Collaboration"
  defp enquiry_type_label("general"), do: "General"
  defp enquiry_type_label(_), do: "General"
end
