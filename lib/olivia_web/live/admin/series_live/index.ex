defmodule OliviaWeb.Admin.SeriesLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Content
  alias Olivia.Content.Series

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Series
      <:actions>
        <.link navigate={~p"/admin/series/new"}>
          <.button>New Series</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="series"
      rows={@streams.series_collection}
      row_click={fn {_id, series} -> JS.navigate(~p"/admin/series/#{series}") end}
    >
      <:col :let={{_id, series}} label="Title"><%= series.title %></:col>
      <:col :let={{_id, series}} label="Slug"><%= series.slug %></:col>
      <:col :let={{_id, series}} label="Position"><%= series.position %></:col>
      <:col :let={{_id, series}} label="Published">
        <span class={[
          "px-2 inline-flex text-xs leading-5 font-semibold rounded-full",
          series.published && "bg-green-100 text-green-800" || "bg-gray-100 text-gray-800"
        ]}>
          <%= if series.published, do: "Yes", else: "No" %>
        </span>
      </:col>
      <:action :let={{_id, series}}>
        <.link navigate={~p"/admin/series/#{series}"}>Show</.link>
      </:action>
      <:action :let={{_id, series}}>
        <.link navigate={~p"/admin/series/#{series}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, series}}>
        <.link
          phx-click={JS.push("delete", value: %{id: series.id}) |> hide("##{id}")}
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
     |> stream(:series_collection, Content.list_series())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Listing Series")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    series = Content.get_series!(id)
    {:ok, _} = Content.delete_series(series)

    {:noreply, stream_delete(socket, :series_collection, series)}
  end
end
