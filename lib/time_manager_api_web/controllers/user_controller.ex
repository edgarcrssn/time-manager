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
end
