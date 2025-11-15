defmodule OliviaWeb.Admin.ExhibitionLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Exhibitions

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Exhibitions
      <:actions>
        <.link navigate={~p"/admin/exhibitions/new"}>
          <.button>New Exhibition</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="exhibitions"
      rows={@streams.exhibitions}
      row_click={fn {_id, exhibition} -> JS.navigate(~p"/admin/exhibitions/#{exhibition}") end}
    >
      <:col :let={{_id, exhibition}} label="Title"><%= exhibition.title %></:col>
      <:col :let={{_id, exhibition}} label="Venue">
        <%= exhibition.venue %>, <%= exhibition.city %>
      </:col>
      <:col :let={{_id, exhibition}} label="Dates">
        <%= Calendar.strftime(exhibition.start_date, "%d %b %Y") %> -
        <%= Calendar.strftime(exhibition.end_date, "%d %b %Y") %>
      </:col>
      <:col :let={{_id, exhibition}} label="Published">
        <span class={[
          "px-2 inline-flex text-xs leading-5 font-semibold rounded-full",
          exhibition.published && "bg-green-100 text-green-800" || "bg-gray-100 text-gray-800"
        ]}>
          <%= if exhibition.published, do: "Yes", else: "No" %>
        </span>
      </:col>
      <:action :let={{_id, exhibition}}>
        <.link navigate={~p"/admin/exhibitions/#{exhibition}"}>Show</.link>
      </:action>
      <:action :let={{_id, exhibition}}>
        <.link navigate={~p"/admin/exhibitions/#{exhibition}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, exhibition}}>
        <.link
          phx-click={JS.push("delete", value: %{id: exhibition.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:exhibitions, Exhibitions.list_exhibitions())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Listing Exhibitions")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    exhibition = Exhibitions.get_exhibition!(id)
    {:ok, _} = Exhibitions.delete_exhibition(exhibition)

    {:noreply, stream_delete(socket, :exhibitions, exhibition)}
  end
end
