defmodule OliviaWeb.ContactLive do
  use OliviaWeb, :live_view

  alias Olivia.Annotations
  alias Olivia.Communications
  alias Olivia.Communications.Enquiry
  alias Olivia.Uploads

  @impl true
  def render(assigns) do
    cond do
      assigns[:theme] == "curator" -> render_curator(assigns)
      assigns[:theme] == "cottage" -> render_cottage(assigns)
      assigns[:theme] == "gallery" -> render_gallery(assigns)
      true -> render_default(assigns)
    end
  end

  defp annotation_attrs(enabled, anchor_key, anchor_meta) do
    if enabled do
      %{
        "data-note-anchor" => anchor_key,
        "data-anchor-meta" => Jason.encode!(anchor_meta),
        "phx-hook" => "AnnotatableElement"
      }
    else
      %{}
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
    <div style="text-align: center; padding: 5rem 1.5rem 3rem; background: linear-gradient(to bottom, #faf8f5, #fff);">
      <h1 class="gallery-heading" style="font-size: 2.5rem; color: #2c2416; margin-bottom: 1rem;">
        Get in Touch
      </h1>
      <div style="width: 60px; height: 1px; background: #c4b5a0; margin: 0 auto 2rem;"></div>
      <p style="font-size: 1.125rem; color: #6b5d54; max-width: 500px; margin: 0 auto; line-height: 1.8;">
        Whether you're interested in purchasing artwork, commissioning a piece, or have a project in mind, I'd love to hear from you.
      </p>
    </div>

    <!-- Contact Form -->
    <div style="max-width: 500px; margin: 0 auto; padding: 3rem 1.5rem 5rem;">
      <.form
        for={@form}
        id="contact-form"
        phx-change="validate"
        phx-submit="submit"
      >
        <div style="display: grid; gap: 1.5rem;">
          <div>
            <label style="display: block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; margin-bottom: 0.5rem;">
              I'm interested in
            </label>
            <select
              name={@form[:type].name}
              style="width: 100%; padding: 0.75rem 1rem; border: 1px solid #c4b5a0; background: #faf8f5; font-size: 1rem; color: #2c2416; outline: none;"
            >
              <option value="artwork" selected={@form[:type].value == "artwork"}>Purchasing artwork</option>
              <option value="commission" selected={@form[:type].value == "commission"}>Commissioning a piece</option>
              <option value="project" selected={@form[:type].value == "project"}>A project collaboration</option>
              <option value="general" selected={@form[:type].value == "general"}>General enquiry</option>
            </select>
          </div>

          <div>
            <label style="display: block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; margin-bottom: 0.5rem;">
              Your name
            </label>
            <input
              type="text"
              name={@form[:name].name}
              value={@form[:name].value}
              required
              style="width: 100%; padding: 0.75rem 1rem; border: 1px solid #c4b5a0; background: #faf8f5; font-size: 1rem; color: #2c2416; outline: none;"
            />
          </div>

          <div>
            <label style="display: block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; margin-bottom: 0.5rem;">
              Email address
            </label>
            <input
              type="email"
              name={@form[:email].name}
              value={@form[:email].value}
              required
              style="width: 100%; padding: 0.75rem 1rem; border: 1px solid #c4b5a0; background: #faf8f5; font-size: 1rem; color: #2c2416; outline: none;"
            />
          </div>

          <div>
            <label style="display: block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; margin-bottom: 0.5rem;">
              Message
            </label>
            <textarea
              name={@form[:message].name}
              rows="6"
              required
              placeholder="Tell me about your enquiry..."
              style="width: 100%; padding: 0.75rem 1rem; border: 1px solid #c4b5a0; background: #faf8f5; font-size: 1rem; color: #2c2416; outline: none; resize: vertical;"
            ><%= @form[:message].value %></textarea>
          </div>
        </div>

        <div style="margin-top: 2.5rem;">
          <button
            type="submit"
            phx-disable-with="Sending..."
            style="width: 100%; padding: 1rem 2rem; background: #6b5d54; color: #faf8f5; font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.15em; border: none; cursor: pointer; transition: background-color 0.2s;"
          >
            Send Message
          </button>
        </div>
      </.form>

      <div style="margin-top: 4rem; padding-top: 2rem; border-top: 1px solid #e8e6e3; text-align: center;">
        <a href="/" style="font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.1em; color: #8b7355; text-decoration: none;">
          ← Back to home
        </a>
      </div>
    </div>
    """
  end

  defp render_default(assigns) do
    ~H"""
    <div class="bg-white px-6 py-24 sm:py-32 lg:px-8">
      <div class="mx-auto max-w-2xl">
        <div
          class="text-center"
          {annotation_attrs(@annotations_enabled, "contact:header", %{"page" => "contact"})}
        >
          <h1 class="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
            Get in Touch
          </h1>
          <p class="mt-6 text-lg leading-8 text-gray-600">
            Whether you're interested in purchasing artwork, commissioning a piece, or have a project in mind, I'd love to hear from you.
          </p>
        </div>

        <div {annotation_attrs(@annotations_enabled, "contact:form", %{"page" => "contact"})}>
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
        </div>

        <div class="mt-16 border-t border-gray-200 pt-8">
          <.link navigate={~p"/"} class="text-sm font-semibold text-gray-900">
            ← Back to home
          </.link>
        </div>
      </div>
    </div>

    <%= if @annotations_enabled do %>
      <div id="annotation-recorder-container">
        <form id="annotation-upload-form" phx-change="noop" phx-submit="noop" phx-hook="AudioAnnotation">
          <.live_file_input upload={@uploads.audio} id="annotation-audio-input" class="hidden" />
        </form>
      </div>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    enquiry = %Enquiry{type: "general"}
    theme = socket.assigns[:theme]
    page_path = "/contact"
    annotations_enabled = theme == "reviewer"

    socket =
      socket
      |> assign(:page_title, "Contact - Olivia Tew")
      |> assign(:form, to_form(Communications.change_enquiry(enquiry)))
      |> assign(:annotations_enabled, annotations_enabled)

    socket = if annotations_enabled do
      existing_notes = Annotations.list_voice_notes(page_path, "reviewer")

      socket
      |> assign(:annotation_mode, false)
      |> assign(:current_anchor, nil)
      |> assign(:page_path, page_path)
      |> assign(:existing_notes, existing_notes)
      |> allow_upload(:audio,
        accept: ~w(audio/*),
        max_entries: 1,
        max_file_size: 10_000_000
      )
      |> push_event("load_existing_notes", %{
        notes: Enum.map(existing_notes, &%{
          id: &1.id,
          anchor_key: &1.anchor_key,
          audio_url: &1.audio_url
        })
      })
    else
      socket
    end

    {:ok, socket}
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

  @impl true
  def handle_event("noop", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("toggle_mode", _, socket) do
    enabled = !socket.assigns.annotation_mode

    {:noreply,
     socket
     |> assign(:annotation_mode, enabled)
     |> push_event("annotation_mode_changed", %{enabled: enabled})}
  end

  @impl true
  def handle_event("start_annotation", params, socket) do
    anchor = %{
      key: params["anchor_key"],
      meta: params["anchor_meta"] || %{}
    }

    {:noreply, assign(socket, :current_anchor, anchor)}
  end

  @impl true
  def handle_event("save_audio_blob", %{"blob" => blob_data, "mime_type" => mime_type, "filename" => filename}, socket) do
    require Logger
    anchor = socket.assigns.current_anchor

    if !anchor do
      {:noreply, put_flash(socket, :error, "No annotation target selected")}
    else
      case Base.decode64(blob_data) do
        {:ok, binary_data} ->
          # Write to temp file first (same as SeriesLive.Show)
          temp_path = Path.join(System.tmp_dir!(), filename)

          case File.write(temp_path, binary_data) do
            :ok ->
              # Generate proper S3 key with path prefix
              clean_filename = Uploads.generate_filename(filename)
              key = "voice_notes/#{clean_filename}"

              case Uploads.upload_file(temp_path, key, mime_type) do
                {:ok, url} ->
                  # Clean up temp file
                  File.rm(temp_path)

                  case Annotations.create_voice_note(%{
                    audio_url: url,
                    anchor_key: anchor.key,
                    anchor_meta: anchor.meta,
                    page_path: socket.assigns.page_path,
                    theme: "reviewer"
                  }) do
                    {:ok, voice_note} ->
                      {:noreply,
                       socket
                       |> put_flash(:info, "Annotation saved successfully")
                       |> assign(:current_anchor, nil)
                       |> push_event("note_created", %{
                         id: voice_note.id,
                         anchor_key: voice_note.anchor_key,
                         audio_url: voice_note.audio_url
                       })}

                    {:error, _changeset} ->
                      {:noreply, put_flash(socket, :error, "Failed to save annotation")}
                  end

                {:error, _reason} ->
                  File.rm(temp_path)
                  {:noreply, put_flash(socket, :error, "Failed to upload audio")}
              end

            {:error, _reason} ->
              {:noreply, put_flash(socket, :error, "Failed to process audio")}
          end

        :error ->
          {:noreply, put_flash(socket, :error, "Invalid audio data")}
      end
    end
  end

  @impl true
  def handle_event("delete_annotation", %{"id" => id}, socket) do
    voice_note = Annotations.get_voice_note!(id)

    case Annotations.delete_voice_note(voice_note) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Annotation deleted")
         |> push_event("annotation_deleted", %{id: id})}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete annotation")}
    end
  end
end
