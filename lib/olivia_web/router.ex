defmodule OliviaWeb.Router do
  use OliviaWeb, :router

  import OliviaWeb.OliviaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OliviaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug OliviaWeb.Plugs.ThemePlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OliviaWeb do
    pipe_through :browser

    live_session :public, on_mount: {OliviaWeb.ThemeHook, :default} do
      live "/", HomeLive, :index

      live "/series", SeriesLive.Index, :index
      live "/series/:slug", SeriesLive.Show, :show

      live "/artworks/:slug", ArtworkLive.Show, :show

      live "/work", WorkLive, :index
      live "/process", ProcessLive, :index

      live "/about", PageLive, :show, as: :page
      live "/collect", PageLive, :show, as: :page
      live "/hotels-designers", PageLive, :show, as: :page
      live "/press-projects", PageLive, :show, as: :page

      live "/contact", ContactLive, :index
    end

    get "/sitemap.xml", SitemapController, :index
    get "/set-theme/:theme", ThemeController, :set_theme
    get "/toggle-theme", ThemeController, :toggle
    get "/gallery", ThemeController, :set_gallery
  end


  ## Admin routes
  scope "/admin", OliviaWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin, layout: {OliviaWeb.Layouts, :admin}, on_mount: {OliviaWeb.OliviaWeb.UserAuth, :ensure_authenticated} do
      live "/", DashboardLive, :index

      live "/series", SeriesLive.Index, :index
      live "/series/:id/edit", SeriesLive.Form, :edit
      live "/series/:id", SeriesLive.Show, :show

      live "/artworks", ArtworkLive.Index, :index
      live "/artworks/new", ArtworkLive.Form, :new
      live "/artworks/:id/edit", ArtworkLive.Form, :edit
      live "/artworks/:id", ArtworkLive.Show, :show

      live "/exhibitions", ExhibitionLive.Index, :index
      live "/exhibitions/new", ExhibitionLive.Form, :new
      live "/exhibitions/:id/edit", ExhibitionLive.Form, :edit
      live "/exhibitions/:id", ExhibitionLive.Show, :show

      live "/press", PressLive.Index, :index
      live "/press/new", PressLive.Form, :new
      live "/press/:id/edit", PressLive.Form, :edit
      live "/press/:id", PressLive.Show, :show

      live "/projects", ProjectLive.Index, :index
      live "/projects/new", ProjectLive.Form, :new
      live "/projects/:id/edit", ProjectLive.Form, :edit
      live "/projects/:id", ProjectLive.Show, :show

      live "/pages", PageLive.Index, :index
      live "/pages/:id", PageLive.Edit, :edit

      live "/subscribers", SubscriberLive.Index, :index

      live "/newsletters", NewsletterLive.Index, :index
      live "/newsletters/new", NewsletterLive.Form, :new
      live "/newsletters/:id/edit", NewsletterLive.Form, :edit

      live "/enquiries", EnquiryLive.Index, :index
      live "/enquiries/:id", EnquiryLive.Show, :show

      live "/media", MediaLive.Workspace, :index
      live "/media/spatial", MediaLive.Spatial, :index
      live "/media/:id/edit", MediaLive.Edit, :edit

      live "/prompt-base", PromptBaseLive.Index, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", OliviaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:olivia, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OliviaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/olivia_web", OliviaWeb.OliviaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
  end

  scope "/olivia_web", OliviaWeb.OliviaWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
  end

  scope "/olivia_web", OliviaWeb.OliviaWeb do
    pipe_through [:browser]

    get "/users/log-in", UserSessionController, :new
    get "/users/log-in/:token", UserSessionController, :confirm
    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
