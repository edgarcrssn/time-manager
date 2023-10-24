defmodule TimeManagerApiWeb.UserController do
  use TimeManagerApiWeb, :controller
  import Ecto.Query

  def index(conn, %{"email" => email, "username" => username} = params) when is_map(params) do
    query = from(
      u in TimeManagerApi.User,
      where: u.email == ^email and u.username == ^username,
      select: [u.id, u.email, u.username]
    )
    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, %{"email" => email} = params) when is_map(params) do
    query = from(
      u in TimeManagerApi.User,
      where: u.email == ^email,
      select: [u.id, u.email, u.username]
    )
    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, %{"username" => username} = params) when is_map(params) do
    query = from(
      u in TimeManagerApi.User,
      where: u.username == ^username,
      select: [u.id, u.email, u.username]
    )
    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def index(conn, _params) do
    query = from(
      u in TimeManagerApi.User,
      select: [u.id, u.email, u.username]
    )
    users = TimeManagerApi.Repo.all(query)
    json(conn, users)
  end

  def show(conn, %{"userID" => id}) do
    user = TimeManagerApi.Repo.get(TimeManagerApi.User, id)
    json(conn, user)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = TimeManagerApi.User.changeset(%TimeManagerApi.User{}, user_params)

    case TimeManagerApi.Repo.insert(changeset) do
      {:ok, user} -> json(conn, user)
      {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> render(TimeManagerApiWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"userID" => id, "user" => user_params}) do
    user = TimeManagerApi.Repo.get!(TimeManagerApi.User, id)
    changeset = TimeManagerApi.User.changeset(user, user_params)

    case TimeManagerApi.Repo.update(changeset) do
      {:ok, user} -> json(conn, user)
      {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> render(TimeManagerApiWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"userID" => id}) do
    user = TimeManagerApi.Repo.get!(TimeManagerApi.User, id)
    {:ok, _} = TimeManagerApi.Repo.delete(user)
    send_resp(conn, :no_content, "")
  end
end
