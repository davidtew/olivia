defmodule OliviaWeb.Admin.SeriesLiveTest do
  use OliviaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Olivia.ContentFixtures

  @create_attrs %{position: 42, title: "some title", slug: "some slug", summary: "some summary", body_md: "some body_md", published: true}
  @update_attrs %{position: 43, title: "some updated title", slug: "some updated slug", summary: "some updated summary", body_md: "some updated body_md", published: false}
  @invalid_attrs %{position: nil, title: nil, slug: nil, summary: nil, body_md: nil, published: false}

  setup :register_and_log_in_user

  defp create_series(%{scope: scope}) do
    series = series_fixture(scope)

    %{series: series}
  end

  describe "Index" do
    setup [:create_series]

    test "lists all series", %{conn: conn, series: series} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/series")

      assert html =~ "Listing Series"
      assert html =~ series.title
    end

    test "saves new series", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Series")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/new")

      assert render(form_live) =~ "New Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-form", series: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series")

      html = render(index_live)
      assert html =~ "Series created successfully"
      assert html =~ "some title"
    end

    test "updates series in listing", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#series-#{series.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/edit")

      assert render(form_live) =~ "Edit Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-form", series: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series")

      html = render(index_live)
      assert html =~ "Series updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes series in listing", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series")

      assert index_live |> element("#series-#{series.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#series-#{series.id}")
    end
  end

  describe "Show" do
    setup [:create_series]

    test "displays series", %{conn: conn, series: series} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/series/#{series}")

      assert html =~ "Show Series"
      assert html =~ series.title
    end

    test "updates series and returns to show", %{conn: conn, series: series} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series/#{series}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/edit?return_to=show")

      assert render(form_live) =~ "Edit Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#series-form", series: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}")

      html = render(show_live)
      assert html =~ "Series updated successfully"
      assert html =~ "some updated title"
    end
  end
end
