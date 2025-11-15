defmodule OliviaWeb.Admin.PressLive.Index do
  use OliviaWeb, :live_view

  alias Olivia.Press

  on_mount {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Press Features
      <:actions>
        <.link navigate={~p"/admin/press/new"}>
          <.button>New Press Feature</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="press_features"
      rows={@streams.press_features}
      row_click={fn {_id, press} -> JS.navigate(~p"/admin/press/#{press}") end}
    >
      <:col :let={{_id, press}} label="Title"><%= press.title %></:col>
      <:col :let={{_id, press}} label="Publication"><%= press.publication %></:col>
      <:col :let={{_id, press}} label="Issue"><%= press.issue || "—" %></:col>
      <:col :let={{_id, press}} label="Date">
        <%= Calendar.strftime(press.date, "%d %b %Y") %>
      </:col>
      <:col :let={{_id, press}} label="Published">
        <span class={[
          "px-2 inline-flex text-xs leading-5 font-semibold rounded-full",
          press.published && "bg-green-100 text-green-800" || "bg-gray-100 text-gray-800"
        ]}>
          <%= if press.published, do: "Yes", else: "No" %>
        </span>
      </:col>
      <:action :let={{_id, press}}>
        <.link navigate={~p"/admin/press/#{press}"}>Show</.link>
      </:action>
      <:action :let={{_id, press}}>
        <.link navigate={~p"/admin/press/#{press}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, press}}>
        <.link
          phx-click={JS.push("delete", value: %{id: press.id}) |> hide("##{id}")}
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
     |> stream(:press_features, Press.list_press_features())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Press Features")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    press = Press.get_press_feature!(id)
    {:ok, _} = Press.delete_press_feature(press)

    {:noreply, stream_delete(socket, :press_features, press)}
  end
end
