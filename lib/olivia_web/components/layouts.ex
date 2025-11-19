defmodule OliviaWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use OliviaWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  @doc """
  Renders the main navigation header for public pages.
  """
  attr :current_scope, :map, default: nil
  attr :theme, :string, default: "original"

  def navigation(assigns) do
    ~H"""
    <nav class="bg-white border-b border-gray-200">
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 justify-between items-center">
          <div class="flex items-center">
            <.link navigate={~p"/"} class="text-2xl font-bold text-gray-900 hover:text-gray-700">
              Olivia Tew
            </.link>
          </div>

          <div class="hidden md:flex md:space-x-8 md:items-center">
            <.link
              navigate={~p"/series"}
              class="text-gray-700 hover:text-gray-900 px-3 py-2 text-sm font-medium"
            >
              Series
            </.link>
            <.link
              navigate={~p"/about"}
              class="text-gray-700 hover:text-gray-900 px-3 py-2 text-sm font-medium"
            >
              About
            </.link>
            <.link
              navigate={~p"/collect"}
              class="text-gray-700 hover:text-gray-900 px-3 py-2 text-sm font-medium"
            >
              Collect
            </.link>
            <.link
              navigate={~p"/hotels-designers"}
              class="text-gray-700 hover:text-gray-900 px-3 py-2 text-sm font-medium"
            >
              Hotels & Designers
            </.link>
            <.link
              navigate={~p"/press-projects"}
              class="text-gray-700 hover:text-gray-900 px-3 py-2 text-sm font-medium"
            >
              Press & Projects
            </.link>
            <.link
              navigate={~p"/contact"}
              class="rounded-md bg-gray-900 px-3.5 py-2 text-sm font-semibold text-white shadow-sm hover:bg-gray-800"
            >
              Contact
            </.link>
            <div class="relative">
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
                <a href="/set-theme/curator" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 border-b border-gray-200">
                  Curator
                </a>
                <a href="/set-theme/original" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 border-b border-gray-200">
                  Original
                </a>
                <a href="/set-theme/gallery" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 border-b border-gray-200">
                  Gallery
                </a>
                <a href="/set-theme/cottage" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                  Cottage
                </a>
              </div>
            </div>
          </div>

          <div class="flex md:hidden">
            <button
              type="button"
              phx-click={JS.toggle(to: "#mobile-menu")}
              class="inline-flex items-center justify-center rounded-md p-2 text-gray-700 hover:bg-gray-100 hover:text-gray-900"
            >
              <span class="sr-only">Open menu</span>
              <svg
                class="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <div id="mobile-menu" class="hidden md:hidden border-t border-gray-200">
        <div class="space-y-1 px-2 pb-3 pt-2">
          <.link
            navigate={~p"/series"}
            class="block rounded-md px-3 py-2 text-base font-medium text-gray-700 hover:bg-gray-50 hover:text-gray-900"
          >
            Series
          </.link>
          <.link
            navigate={~p"/about"}
            class="block rounded-md px-3 py-2 text-base font-medium text-gray-700 hover:bg-gray-50 hover:text-gray-900"
          >
            About
          </.link>
          <.link
            navigate={~p"/collect"}
            class="block rounded-md px-3 py-2 text-base font-medium text-gray-700 hover:bg-gray-50 hover:text-gray-900"
          >
            Collect
          </.link>
          <.link
            navigate={~p"/hotels-designers"}
            class="block rounded-md px-3 py-2 text-base font-medium text-gray-700 hover:bg-gray-50 hover:text-gray-900"
          >
            Hotels & Designers
          </.link>
          <.link
            navigate={~p"/press-projects"}
            class="block rounded-md px-3 py-2 text-base font-medium text-gray-700 hover:bg-gray-50 hover:text-gray-900"
          >
            Press & Projects
          </.link>
          <.link
            navigate={~p"/contact"}
            class="block rounded-md px-3 py-2 text-base font-medium bg-gray-900 text-white hover:bg-gray-800"
          >
            Contact
          </.link>

          <div class="px-3 py-2">
            <div class="text-sm font-semibold text-gray-500 mb-2">Theme</div>
            <div class="space-y-1">
              <a
                href="/set-theme/curator"
                class="block rounded-md px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900"
              >
                Curator
              </a>
              <a
                href="/set-theme/original"
                class="block rounded-md px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900"
              >
                Original
              </a>
              <a
                href="/set-theme/gallery"
                class="block rounded-md px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900"
              >
                Gallery
              </a>
              <a
                href="/set-theme/cottage"
                class="block rounded-md px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900"
              >
                Cottage
              </a>
            </div>
          </div>

        </div>
      </div>
    </nav>
    """
  end

  @doc """
  Renders the footer for public pages.
  """
  def footer(assigns) do
    ~H"""
    <footer class="bg-gray-50 border-t border-gray-200 mt-auto">
      <div class="mx-auto max-w-7xl px-6 py-12 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 class="text-sm font-semibold text-gray-900">Navigation</h3>
            <ul class="mt-4 space-y-2">
              <li>
                <.link navigate={~p"/series"} class="text-sm text-gray-600 hover:text-gray-900">
                  Series
                </.link>
              </li>
              <li>
                <.link navigate={~p"/about"} class="text-sm text-gray-600 hover:text-gray-900">
                  About
                </.link>
              </li>
              <li>
                <.link navigate={~p"/collect"} class="text-sm text-gray-600 hover:text-gray-900">
                  Collect
                </.link>
              </li>
              <li>
                <.link navigate={~p"/contact"} class="text-sm text-gray-600 hover:text-gray-900">
                  Contact
                </.link>
              </li>
            </ul>
          </div>

          <div>
            <h3 class="text-sm font-semibold text-gray-900">Connect</h3>
            <ul class="mt-4 space-y-2">
              <li>
                <a
                  href="https://instagram.com/oliviatewstudio"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-sm text-gray-600 hover:text-gray-900"
                >
                  Instagram
                </a>
              </li>
              <li>
                <a
                  href="mailto:olivia.tew@gmail.com"
                  class="text-sm text-gray-600 hover:text-gray-900"
                >
                  Email
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h3 class="text-sm font-semibold text-gray-900">Newsletter</h3>
            <p class="mt-4 text-sm text-gray-600">
              Subscribe to receive updates about new work and exhibitions.
            </p>
            <.link
              navigate={~p"/"}
              class="mt-4 inline-block text-sm font-semibold text-gray-900 hover:text-gray-700"
            >
              Subscribe →
            </.link>
          </div>
        </div>

        <div class="mt-8 border-t border-gray-200 pt-8">
          <p class="text-xs text-gray-500 text-center">
            © {Date.utc_today().year} Olivia Tew. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
    """
  end
end
