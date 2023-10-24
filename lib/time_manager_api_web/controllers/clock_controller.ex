defmodule TimeManagerApiWeb.ClockController do
  use TimeManagerApiWeb, :controller
  import Ecto.Query

  def show(conn, %{"userID" => user_id}) when is_binary(user_id) do
    user_id = String.to_integer(user_id)

    try do
      clocks = TimeManagerApi.Repo.all(from c in TimeManagerApi.Clock, where: c.user_id == ^user_id)
      case clocks do
        [] ->
          conn
          |> put_status(:not_found)
          |> json(%{"message" => "Clock not found"})
        _ ->
          conn
          |> put_status(:ok)
          |> json(clocks)
      end
    rescue
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"message" => "Internal Server Error"})
    end
  end


  def create(conn, %{"userID" => user_id, "clock" => clock_params}) when is_binary(user_id) do
    user_id = String.to_integer(user_id)
    changeset = TimeManagerApi.Clock.changeset(%TimeManagerApi.Clock{}, Map.merge(clock_params, %{"user_id" => user_id}))

    try do
      case TimeManagerApi.Repo.insert(changeset) do
        {:ok, clock} ->
          conn
          |> put_status(:created)
          |> json(%{"message" => "Clock correctly created"})
          |> json(clock)
        {:error, changeset} ->
          conn
          |> put_status(:bad_request)
          |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} -> msg end)})
      end
    rescue
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"message" => "Internal Server Error"})
    end
  end
end
