defmodule TimeManagerApiWeb.UserController do
  use TimeManagerApiWeb, :controller
  import Ecto.Query

  @doc """
  Retrieve users. Can be filtered by email and/or username.
  """
  def index(conn, %{"email" => email, "username" => username} = params) when is_map(params) do
    query =
      from(
        u in TimeManagerApi.User,
        where: u.email == ^email and u.username == ^username
      )

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, %{"email" => email} = params) when is_map(params) do
    query =
      from(
        u in TimeManagerApi.User,
        where: u.email == ^email
      )

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, %{"username" => username} = params) when is_map(params) do
    query =
      from(
        u in TimeManagerApi.User,
        where: u.username == ^username
      )

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, _params) do
    query =
      from(u in TimeManagerApi.User)

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  @doc """
  Retrieve a user by id.
  """
  def show(conn, %{"userID" => id}) do
    user = TimeManagerApi.Repo.get(TimeManagerApi.User, id)

    case user do
      %TimeManagerApi.User{} = user ->
        json(conn, user)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User with id #{id} does not exist"})
    end
  end

  @doc """
  Create a new user.
  """
  def create(conn, %{"user" => user_params}) do
    changeset = TimeManagerApi.User.changeset(%TimeManagerApi.User{}, user_params)

    user_password = user_params["password"]
    pattern = ~r/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/

    if !Regex.match?(pattern, user_password) do
      conn
      |> put_status(:bad_request)
      |> json(%{message: "Password is too weak"})
    else
      case TimeManagerApi.Repo.insert(changeset) do
        {:ok, user} ->
          conn
          |> put_status(:created)
          |> json(%{user: user})

        {:error, changeset} ->
          if Enum.any?(changeset.errors, fn {field, error} ->
              field == :email and
                error ==
                  {"has already been taken",
                  [constraint: :unique, constraint_name: "users_email_index"]}
            end) do
            conn
            |> put_status(:conflict)
            |> json(%{message: "Email is already taken"})
          else
            conn
            |> put_status(:bad_request)
            |> json(%{message: "Bad Request"})
          end
      end
    end
  end

  @doc """
  Update an existing user by id.
  """
  def update(conn, %{"userID" => id, "user" => user_params}) do
    user = TimeManagerApi.Repo.get(TimeManagerApi.User, id)

    case user do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "User not found"})

      _user ->
        changeset = TimeManagerApi.User.changeset(user, user_params)

        case TimeManagerApi.Repo.update(changeset) do
          {:ok, updated_user} ->
            conn
            |> put_status(:ok)
            |> json(%{user: updated_user})

          {:error, changeset} ->
            if Enum.any?(changeset.errors, fn {field, error} ->
                 field == :email and
                   error ==
                     {"has already been taken",
                      [constraint: :unique, constraint_name: "users_email_index"]}
               end) do
              conn
              |> put_status(:conflict)
              |> json(%{message: "Email is already taken"})
            else
              conn
              |> put_status(:bad_request)
              |> json(%{message: "Bad Request"})
            end
        end
    end
  end

  @doc """
  Delete an existing user by id.
  """
  def delete(conn, %{"userID" => id}) do
    user = TimeManagerApi.Repo.get(TimeManagerApi.User, id)

    case user do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "User not found"})

      _ ->
        case TimeManagerApi.Repo.delete(user) do
          {:ok, _} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "User deleted"})

          _ ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{message: "Failed to delete user"})
        end
    end
  end

  def getByTeam(conn, %{"teamId" => teamId}) do
    teamId = String.to_integer(teamId)
    team = TimeManagerApi.Repo.get(TimeManagerApi.Team, teamId)

    case team do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "The team with the id #{teamId} doesn't exist"})

      _ ->
        query =
          from(ut in TimeManagerApi.UserTeam,
            join: u in assoc(ut, :user),
            where: ut.team_id == ^teamId,
            select: u
          )

        users = TimeManagerApi.Repo.all(query)

        conn
        |> put_status(:ok)
        |> json(users)
    end
  end

  def getTeamMates(conn, %{"userId" => userId}) do
    query =
      from(
        ut in TimeManagerApi.UserTeam,
        join: u in assoc(ut, :user),
        where: ut.user_id == ^userId,
        select: ut.team_id
      )

    nestedQuery =
      from(
        u in TimeManagerApi.User,
        join: ut in TimeManagerApi.UserTeam,
        on: u.id == ut.user_id,
        where: ut.team_id in subquery(query)
      )

    users = TimeManagerApi.Repo.all(nestedQuery)

    case users do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "There is no team-mates for the user with the id #{userId}"})

      _ ->
        conn
        |> put_status(:ok)
        |> json(users)
    end

    json(conn, users)
  end
end
