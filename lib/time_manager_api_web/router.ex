defmodule TimeManagerApiWeb.Router do
  use TimeManagerApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TimeManagerApiWeb do
    pipe_through :api

    get "/workingtimes/:userID", WorkingtimesController, :getall

    get "/workingtimes/:userID/:id", WorkingtimesController, :getone

    post "/workingtimes/:userID", WorkingtimesController, :create

    put "/workingtimes/:id", WorkingtimesController, :update

    delete "/workingtimes/:id", WorkingtimesController, :delete

    scope "/clocks" do
      get "/:userID", ClockController, :show
      post "/:userID", ClockController, :create
    end

    scope "/users" do
      get "", UserController, :index
      get "/:userID", UserController, :show
      post "", UserController, :create
      put "/:userID", UserController, :update
      delete "/:userID", UserController, :delete
    end
  end


  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:time_manager_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/api" do
      pipe_through [:fetch_session, :protect_from_forgery]


    end
  end
end
