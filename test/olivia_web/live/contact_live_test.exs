defmodule OliviaWeb.ContactLiveTest do
  use OliviaWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Contact form" do
    test "renders contact page", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/contact")

      assert html =~ "Get in Touch"
      assert html =~ "name"
      assert html =~ "email"
      assert html =~ "message"
    end

    test "submits enquiry with valid data", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/contact")

      assert live
             |> form("#contact-form",
               enquiry: %{
                 name: "Jane Doe",
                 email: "jane@example.com",
                 type: "general",
                 message: "I love your work!"
               }
             )
             |> render_submit()

      assert_redirected(live, ~p"/")
    end

    test "shows validation errors for invalid data", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/contact")

      result =
        live
        |> form("#contact-form",
          enquiry: %{
            name: "",
            email: "invalid-email",
            type: "general",
            message: ""
          }
        )
        |> render_change()

      assert result =~ "can&#39;t be blank"
    end

    test "validates email format", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/contact")

      result =
        live
        |> form("#contact-form",
          enquiry: %{
            name: "Test User",
            email: "not-an-email",
            type: "general",
            message: "Hello"
          }
        )
        |> render_change()

      assert result =~ "must have the @ sign"
    end
  end
end
