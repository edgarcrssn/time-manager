defmodule TimeManagerApiWeb.Router do
  use TimeManagerApiWeb, :router

  pipeline :api do
    plug :accepts, ["json", "html"]
  end

  scope "/", TimeManagerApiWeb, as: :browser do
    get "/", HomeController, :index
  end

  scope "/api", TimeManagerApiWeb do
    pipe_through :api

    scope "/workingtimes" do
      get "/:userID", WorkingtimesController, :index
      get "/:userID/:id", WorkingtimesController, :show
      post "/:userID", WorkingtimesController, :create
      put "/:id", WorkingtimesController, :update
      delete "/:id", WorkingtimesController, :delete
    end

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
      get "/team/:teamId", UserController, :getByTeam
      get "/teamMate/:userId", UserController, :getTeamMates
    end

    scope "/teams" do
      get "", TeamController, :getAllTeam
      get "/:teamId", TeamController, :getById
      post "", TeamController, :create
      put "/:teamId", TeamController, :update
      delete "/:teamId", TeamController, :delete
      post "/:userId/:teamId", TeamController, :addUserTeam
      delete "/:userId/:teamId", TeamController, :deleteUserTeam
    end

    scope "/schedules" do
      get "/:userID", EmployeeScheduleController, :index
      post "/:userID", EmployeeScheduleController, :create
      put "/:userID", EmployeeScheduleController, :update
      delete "/:userID", EmployeeScheduleController, :delete
    end
  end


  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:time_manager_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    # import Phoenix.LiveDashboard.Router

    scope "/api" do
      pipe_through [:fetch_session, :protect_from_forgery]


    end
  end
end
