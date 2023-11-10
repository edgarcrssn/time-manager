defmodule TimeManagerApiWeb.Router do
  use TimeManagerApiWeb, :router

  pipeline :api do
    plug :accepts, ["json", "html"]
  end

  pipeline :authenticated do
    plug TimeManagerApiWeb.Plugs.VerifyJWT
  end

  pipeline :authorize_user_himself_only do
    plug TimeManagerApi.Plugs.Authorization, opts: ["is_user_himself"]
  end
  pipeline :authorize_manager_only do
    plug TimeManagerApi.Plugs.Authorization, opts: ["is_manager"]
  end
  pipeline :authorize_manager_or_user_himself do
    plug TimeManagerApi.Plugs.Authorization, opts: ["is_manager", "is_user_himself"]
  end
  pipeline :authorize_general_manager_only do
    plug TimeManagerApi.Plugs.Authorization
  end

  scope "/", TimeManagerApiWeb do
    pipe_through :api

    get "/", HomeController, :index

    post "/login", AuthController, :login
    post "/register", AuthController, :register
    post "/logout", AuthController, :logout

    scope "/api" do
      pipe_through [:authenticated]

      scope "/workingtimes" do
        scope "/" do
          get "/:userID", WorkingtimesController, :index, [pipe_through [:authorize_manager_or_user_himself]]
        end
        scope "/" do
          get "/:userID/:id", WorkingtimesController, :show, [pipe_through [:authorize_manager_or_user_himself]]
        end
        scope "/" do
          post "/:userID", WorkingtimesController, :create, [pipe_through [:authorize_manager_or_user_himself]]
        end
        put "/:id", WorkingtimesController, :update
        delete "/:id", WorkingtimesController, :delete
      end

      scope "/clocks" do
        scope "/" do
          get "/:userID", ClockController, :show, [pipe_through [:authorize_manager_or_user_himself]]
        end
        scope "/" do
          get "/:userID/last", ClockController, :getLastClock, [pipe_through [:authorize_manager_or_user_himself]]
        end
        scope "/" do
          post "/:userID", ClockController, :create, [pipe_through [:authorize_manager_or_user_himself]]
        end
        scope "/" do
          post "/team/:teamID", ClockController, :createForMyTeam, [pipe_through [:authorize_manager_only]]
        end
      end

      scope "/users" do
        get "", UserController, :index
        get "/:userID", UserController, :show
        scope "/" do
          post "", UserController, :create, [pipe_through [:authorize_general_manager_only]]
        end
        scope "/" do
          put "/:userID", UserController, :update, [pipe_through [:authorize_user_himself_only]]
        end
        scope "/" do
          delete "/:userID", UserController, :delete, [pipe_through [:authorize_user_himself_only]]
        end
        get "/team/:teamId", UserController, :getByTeam
        get "/teamMate/:userId", UserController, :getTeamMates
      end

      scope "/teams" do
        get "", TeamController, :getAllTeams
        get "/:teamId", TeamController, :getTeamById
        get "/:teamId/users", TeamController, :getTeamUsersById
        scope "/" do
          pipe_through [:authorize_user_himself_only]
          get "/member/:userId", TeamController, :getTeamsImMemberOf
          get "/owned/:userId", TeamController, :getMyOwnedTeams
        end
        scope "/" do
          post "", TeamController, :create, [pipe_through [:authorize_manager_only]]
        end
        scope "/" do
          patch "/:teamId", TeamController, :update, [pipe_through [:authorize_manager_only]]
        end
        scope "/" do
          delete "/:teamId", TeamController, :delete, [pipe_through [:authorize_manager_only]]
        end
        scope "/" do
          post "/:userId/:teamId", TeamController, :addUserIntoTeam, [pipe_through [:authorize_manager_only]]
        end
        scope "/" do
          delete "/:userId/:teamId", TeamController, :deleteUserFromTeam, [pipe_through [:authorize_manager_or_user_himself]]
        end
        patch "/:teamId/grant-owner/:userId", TeamController, :grantOwnerRole
      end

      scope "/schedules" do
        pipe_through [:authorize_user_himself_only]
        get "/:userID", EmployeeScheduleController, :index
        post "/:userID", EmployeeScheduleController, :create
        put "/:userID", EmployeeScheduleController, :update
        delete "/:userID", EmployeeScheduleController, :delete
      end
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
