defmodule OliviaWeb.ThemeComponents do
  @moduledoc """
  Shared components for theme switching across all layouts.

  This pattern can be reused for i18n/locale switching by:
  1. Creating a LocaleComponents module with similar structure
  2. Using a locale cookie instead of theme cookie
  3. Storing locale in session for server-side rendering
  """
  use Phoenix.Component

  @themes [
    %{id: "curator", label: "Curator", description: "Gallery-inspired dark theme"},
    %{id: "gallery", label: "Gallery", description: "Elegant warm tones"},
    %{id: "cottage", label: "Cottage", description: "Soft wisteria garden"},
    %{id: "reviewer", label: "Reviewer", description: "Private review mode with annotations"},
    %{id: "original", label: "Original", description: "Clean and modern"}
  ]

  @doc """
  Returns themes that should be shown in public dropdowns.
  Excludes the secret reviewer theme.
  """
  def public_themes do
    Enum.filter(@themes, fn t -> t.id != "reviewer" end)
  end

  @doc """
  Returns all available themes.
  """
  def themes, do: @themes

  @doc """
  Returns theme IDs as a list (for validation).
  """
  def theme_ids, do: Enum.map(@themes, & &1.id)

  @doc """
  Get a theme by ID.
  """
  def get_theme(id) do
    Enum.find(@themes, fn t -> t.id == id end)
  end

  @doc """
  Renders a theme switcher dropdown styled for the curator theme.

  ## Examples

      <.theme_switcher_curator />
  """
  attr :class, :string, default: ""

  def theme_switcher_curator(assigns) do
    ~H"""
    <div class={"curator-dropdown #{@class}"}>
      <button class="curator-nav-link" style="background: none; border: none; cursor: pointer;">
        Theme
      </button>
      <div class="curator-dropdown-content">
        <%= for theme <- @themes do %>
          <a href={"/set-theme/#{theme.id}"} class="curator-dropdown-item">
            <%= theme.label %>
          </a>
        <% end %>
      </div>
    </div>
    """
    |> then(fn template ->
      assigns = assign(assigns, :themes, @themes)
      template
    end)
  end

  @doc """
  Renders a theme switcher dropdown styled for the gallery theme.
  """
  attr :class, :string, default: ""

  def theme_switcher_gallery(assigns) do
    assigns = assign(assigns, :themes, @themes)

    ~H"""
    <div class={"relative #{@class}"}>
      <button
        onclick="this.nextElementSibling.classList.toggle('hidden')"
        style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #6b5d54; background: none; border: none; cursor: pointer; padding: 0.5rem;"
      >
        Theme ▾
      </button>
      <div class="hidden absolute right-0 mt-2 w-40 bg-white border border-gray-200 rounded shadow-lg z-50">
        <%= for theme <- @themes do %>
          <a
            href={"/set-theme/#{theme.id}"}
            style="display: block; padding: 0.5rem 1rem; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #6b5d54; text-decoration: none;"
            onmouseover="this.style.background='#f5f3f0'"
            onmouseout="this.style.background='transparent'"
          >
            <%= theme.label %>
          </a>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a theme switcher dropdown styled for the cottage theme.
  """
  attr :class, :string, default: ""

  def theme_switcher_cottage(assigns) do
    assigns = assign(assigns, :themes, @themes)

    ~H"""
    <div class={"relative #{@class}"}>
      <button
        onclick="this.nextElementSibling.classList.toggle('hidden')"
        style="font-family: 'Montserrat', sans-serif; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--cottage-text-medium); background: none; border: none; cursor: pointer; padding: 0.5rem;"
      >
        Theme ▾
      </button>
      <div class="hidden absolute right-0 mt-2 w-40 bg-white border rounded shadow-lg z-50" style="border-color: var(--cottage-taupe);">
        <%= for theme <- @themes do %>
          <a
            href={"/set-theme/#{theme.id}"}
            style="display: block; padding: 0.5rem 1rem; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--cottage-text-medium); text-decoration: none;"
            class="hover:bg-gray-50"
          >
            <%= theme.label %>
          </a>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a theme switcher dropdown styled for the original/default theme.
  """
  attr :class, :string, default: ""

  def theme_switcher_original(assigns) do
    assigns = assign(assigns, :themes, @themes)

    ~H"""
    <div class={"relative #{@class}"}>
      <button
        id="theme-dropdown-toggle"
        onclick="document.getElementById('theme-dropdown-menu').classList.toggle('hidden')"
        class="text-gray-700 hover:text-gray-900 px-3 py-2 text-sm font-medium border border-gray-300 rounded-md flex items-center gap-1"
      >
        Theme
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"/>
        </svg>
      </button>
      <div
        id="theme-dropdown-menu"
        class="hidden absolute right-0 mt-2 w-40 bg-white border border-gray-200 rounded-md shadow-lg z-50"
      >
        <%= for {theme, idx} <- Enum.with_index(@themes) do %>
          <a
            href={"/set-theme/#{theme.id}"}
            class={"block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 #{if idx < length(@themes) - 1, do: "border-b border-gray-200", else: ""}"}
          >
            <%= theme.label %>
          </a>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a mobile-friendly theme list (no dropdown, just links).
  Useful for mobile navigation menus.
  """
  attr :style, :string, default: "original"
  attr :class, :string, default: ""

  def theme_list_mobile(assigns) do
    assigns = assign(assigns, :themes, @themes)

    ~H"""
    <div class={@class}>
      <%= case @style do %>
        <% "curator" -> %>
          <span class="curator-label">Theme</span>
          <div style="display: flex; gap: 1rem; margin-top: 0.5rem;">
            <%= for theme <- @themes do %>
              <a href={"/set-theme/#{theme.id}"} class="curator-nav-link" style="font-size: 0.6875rem;">
                <%= theme.label %>
              </a>
            <% end %>
          </div>
        <% "gallery" -> %>
          <div style="font-size: 0.75rem; font-weight: 600; color: #6b5d54; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 0.1em;">Theme</div>
          <div style="display: flex; flex-wrap: wrap; gap: 0.75rem;">
            <%= for theme <- @themes do %>
              <a href={"/set-theme/#{theme.id}"} style="font-size: 0.75rem; color: #8b7355; text-decoration: none;">
                <%= theme.label %>
              </a>
            <% end %>
          </div>
        <% "cottage" -> %>
          <div style="font-size: 0.75rem; font-weight: 500; color: var(--cottage-text-light); margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 0.1em;">Theme</div>
          <div style="display: flex; flex-wrap: wrap; gap: 0.75rem;">
            <%= for theme <- @themes do %>
              <a href={"/set-theme/#{theme.id}"} style="font-size: 0.75rem; color: var(--cottage-wisteria); text-decoration: none;">
                <%= theme.label %>
              </a>
            <% end %>
          </div>
        <% _ -> %>
          <div class="text-sm font-semibold text-gray-500 mb-2">Theme</div>
          <div class="space-y-1">
            <%= for theme <- @themes do %>
              <a
                href={"/set-theme/#{theme.id}"}
                class="block rounded-md px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900"
              >
                <%= theme.label %>
              </a>
            <% end %>
          </div>
      <% end %>
    </div>
    """
  end
end
