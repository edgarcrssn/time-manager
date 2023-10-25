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
        where: u.email == ^email and u.username == ^username,
        select: %{id: u.id, email: u.email, username: u.username}
      )

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, %{"email" => email} = params) when is_map(params) do
    query =
      from(
        u in TimeManagerApi.User,
        where: u.email == ^email,
        select: %{id: u.id, email: u.email, username: u.username}
      )

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, %{"username" => username} = params) when is_map(params) do
    query =
      from(
        u in TimeManagerApi.User,
        where: u.username == ^username,
        select: %{id: u.id, email: u.email, username: u.username}
      )

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, _params) do
    query =
      from(
        u in TimeManagerApi.User,
        select: %{id: u.id, email: u.email, username: u.username}
      )

    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end


  @doc """
  Retrieve a user by id.
  """
  def show(conn, %{"userID" => id}) do
    case TimeManagerApi.Repo.get(TimeManagerApi.User, id) do
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

      _ ->
        changeset = TimeManagerApi.User.changeset(user, user_params)

        case TimeManagerApi.Repo.update(changeset) do
          {:ok, updated_user} ->
            conn
            |> put_status(:ok)
            |> json(%{user: updated_user})

          {:error, changeset} ->
            if Enum.any?(changeset.errors, fn {field, error} ->
                field == :email and
                error == {"has already been taken", [constraint: :unique, constraint_name: "users_email_index"]}
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
end
