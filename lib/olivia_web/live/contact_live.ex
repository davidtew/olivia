defmodule OliviaWeb.ContactLive do
  use OliviaWeb, :live_view

  alias Olivia.Communications
  alias Olivia.Communications.Enquiry

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "curator" -> render_curator(assigns)
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      true -> render_default(assigns)
    end
  end

  defp render_curator(assigns) do
    ~H"""
    <!-- Flash Messages -->
    <div :if={Phoenix.Flash.get(@flash, :info) || Phoenix.Flash.get(@flash, :error)} style="max-width: 1200px; margin: 0 auto; padding: 1rem 2rem 0;">
      <p :if={Phoenix.Flash.get(@flash, :info)} class="curator-body" style="background: var(--curator-sage); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :info) %>
      </p>
      <p :if={Phoenix.Flash.get(@flash, :error)} class="curator-body" style="background: var(--curator-coral); color: white; padding: 1rem 1.5rem; border-radius: 4px;">
        <%= Phoenix.Flash.get(@flash, :error) %>
      </p>
    </div>

    <!-- Page Header -->
    <section style="padding: 4rem 2rem 2rem; text-align: center;">
      <h1 class="curator-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
        Contact
      </h1>
      <p class="curator-body" style="color: var(--curator-text-muted); max-width: 500px; margin: 0 auto;">
        For collector enquiries, exhibition proposals, commission discussions, or press requests.
      </p>
    </section>

    <!-- Contact Form -->
    <section style="padding: 2rem;">
      <div style="max-width: 500px; margin: 0 auto;">
        <.form
          for={@form}
          id="contact-form"
          phx-change="validate"
          phx-submit="submit"
        >
          <div style="display: grid; gap: 1.5rem;">
            <div>
              <label class="curator-label">I'm interested in</label>
              <select
                name={@form[:type].name}
                class="curator-input"
              >
                <option value="artwork" selected={@form[:type].value == "artwork"}>Purchasing artwork</option>
                <option value="commission" selected={@form[:type].value == "commission"}>Commissioning a piece</option>
                <option value="project" selected={@form[:type].value == "project"}>A project collaboration</option>
                <option value="general" selected={@form[:type].value == "general"}>General enquiry</option>
              </select>
            </div>

            <div>
              <label class="curator-label">Your name</label>
              <input
                type="text"
                name={@form[:name].name}
                value={@form[:name].value}
                class="curator-input"
                required
              />
            </div>

            <div>
              <label class="curator-label">Email address</label>
              <input
                type="email"
                name={@form[:email].name}
                value={@form[:email].value}
                class="curator-input"
                required
              />
            </div>

            <div>
              <label class="curator-label">Message</label>
              <textarea
                name={@form[:message].name}
                class="curator-input"
                rows="6"
                required
                placeholder="Tell me about your enquiry..."
              ><%= @form[:message].value %></textarea>
            </div>
          </div>

          <div style="margin-top: 2rem;">
            <button
              type="submit"
              phx-disable-with="Sending..."
              class="curator-button curator-button-primary"
              style="width: 100%; padding: 1rem 2rem;"
            >
              Send Message
            </button>
          </div>
        </.form>

        <!-- Back link -->
        <div style="margin-top: 3rem; padding-top: 2rem; border-top: 1px solid rgba(245, 242, 237, 0.1); text-align: center;">
          <a href="/" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.15em; color: var(--curator-text-muted); text-decoration: none;">
            ← Back to home
          </a>
        </div>
      </div>
    </section>
    """
  end

  defp render_cottage(assigns) do
    ~H"""
    <div style="max-width: 600px; margin: 0 auto; padding: 4rem 1rem;">
      <div style="text-align: center; margin-bottom: 4rem;">
        <h1 class="cottage-heading" style="font-size: 2.5rem; margin-bottom: 1rem;">
          Get in Touch
        </h1>
        <p class="cottage-body" style="font-size: 1.125rem; color: var(--cottage-text-medium); max-width: 48rem; margin: 0 auto;">
          Whether you're interested in purchasing artwork, commissioning a piece, or have a project in mind, I'd love to hear from you.
        </p>
      </div>

      <.form
        for={@form}
        id="contact-form"
        phx-change="validate"
        phx-submit="submit"
        class="cottage-form"
      >
        <div style="display: grid; gap: 1.5rem;">
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

        <div style="margin-top: 2.5rem;">
          <button
            type="submit"
            phx-disable-with="Sending..."
            class="cottage-button"
            style="width: 100%; padding: 1rem 2rem;"
          >
            Send Message
          </button>
        </div>
      </.form>

      <div style="margin-top: 4rem; padding-top: 2rem; border-top: 1px solid var(--cottage-taupe); text-align: center;">
        <.link
          navigate={~p"/"}
          class="cottage-body"
          style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-wisteria); text-decoration: none; border-bottom: 1px solid var(--cottage-wisteria); padding-bottom: 0.25rem;"
        >
          ← Back to home
        </.link>
      </div>
    </div>
    """
  end

  defp render_gallery(assigns) do
    ~H"""
    <!-- Gallery Hero -->
    <div style="text-align: center; padding: 4rem 1.5rem; border-bottom: 1px solid #e8e6e3;">
      <h1 class="gallery-heading" style="font-size: 3rem; color: #2c2416; margin-bottom: 1rem;">
        Get in Touch
      </h1>
      <p class="gallery-script" style="font-size: 1.25rem; color: #6b5d54; max-width: 48rem; margin: 0 auto;">
        Whether you're interested in purchasing artwork, commissioning a piece, or have a project in mind, I'd love to hear from you.
      </p>
    </div>

    <!-- Contact Form -->
    <div style="max-width: 42rem; margin: 0 auto; padding: 4rem 1.5rem;">
      <.form
        for={@form}
        id="contact-form"
        phx-change="validate"
        phx-submit="submit"
        class="gallery-form"
      >
        <div style="display: grid; gap: 1.5rem;">
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

        <div style="margin-top: 2.5rem;">
          <button
            type="submit"
            phx-disable-with="Sending..."
            style="width: 100%; padding: 1rem 2rem; background: #6b5d54; color: #faf8f5; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; text-decoration: none; border: none; cursor: pointer; transition: background-color 0.2s;"
          >
            Send Message
          </button>
        </div>
      </.form>

      <div style="margin-top: 4rem; padding-top: 2rem; border-top: 1px solid #e8e6e3; text-align: center;">
        <.link navigate={~p"/"} style="font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; color: #8b7355; text-decoration: none; border-bottom: 1px solid #c4b5a0; padding-bottom: 0.25rem;">
          ← Back to home
        </.link>
      </div>
    </div>
    """
  end

  defp render_default(assigns) do
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
