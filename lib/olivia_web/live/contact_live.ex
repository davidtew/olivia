defmodule OliviaWeb.ContactLive do
  use OliviaWeb, :live_view

  alias Olivia.Communications
  alias Olivia.Communications.Enquiry

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white px-6 py-24 sm:py-32 lg:px-8">
      <div class="mx-auto max-w-2xl">
        <div class="text-center">
          <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
            Get in Touch
          </h1>
          <p class="mt-6 text-lg leading-8 text-gray-600">
            Whether you're interested in purchasing artwork, commissioning a piece, or have a project in mind, I'd love to hear from you.
          </p>
        </div>

        <.form
          for={@form}
          id="contact-form"
          phx-change="validate"
          phx-submit="submit"
          class="mt-16"
        >
          <div class="grid grid-cols-1 gap-x-8 gap-y-6">
            <div>
              <.input
                field={@form[:type]}
                type="select"
                label="I'm interested in"
                options={[
                  {"Purchasing artwork", "artwork"},
                  {"Commissioning a piece", "commission"},
                  {"A project collaboration", "project"},
                  {"General enquiry", "general"}
                ]}
              />
            </div>

            <div>
              <.input field={@form[:name]} type="text" label="Your name" required />
            </div>

            <div>
              <.input field={@form[:email]} type="email" label="Email address" required />
            </div>

            <div>
              <.input
                field={@form[:message]}
                type="textarea"
                label="Message"
                rows="6"
                required
                placeholder="Tell me about your enquiry..."
              />
            </div>
          </div>

          <div class="mt-10">
            <.button
              phx-disable-with="Sending..."
              class="w-full rounded-md bg-gray-900 px-3.5 py-2.5 text-center text-sm font-semibold text-white shadow-sm hover:bg-gray-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gray-600"
            >
              Send message
            </.button>
          </div>
        </.form>

        <div class="mt-16 border-t border-gray-200 pt-8">
          <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900">
            ← Back to home
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    enquiry = %Enquiry{type: "general"}

    {:ok,
     socket
     |> assign(:page_title, "Contact - Olivia Tew")
     |> assign(:form, to_form(Communications.change_enquiry(enquiry)))}
  end

  @impl true
  def handle_event("validate", %{"enquiry" => enquiry_params}, socket) do
    changeset =
      %Enquiry{}
      |> Communications.change_enquiry(enquiry_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("submit", %{"enquiry" => enquiry_params}, socket) do
    case Communications.create_enquiry(enquiry_params) do
      {:ok, _enquiry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thank you for your message! I'll get back to you soon.")
         |> push_navigate(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
