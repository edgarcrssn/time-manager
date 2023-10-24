defmodule TimeManagerApiWeb.ClockController do
  use TimeManagerApiWeb, :controller
  import Ecto.Query

  def show(conn, %{"userID" => user_id}) when is_binary(user_id) do
    user_id = String.to_integer(user_id)

    try do
      clocks = TimeManagerApi.Repo.all(from c in TimeManagerApi.Clock, where: c.user_id == ^user_id)
      case clocks do
        [] -> send_resp(conn, 404, "Clock not found")
        _ -> json(conn, clocks)
      end
    rescue
      _ -> send_resp(conn, 500, "Internal Server Error")
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
          |> json(clock)
        {:error, changeset} ->
          conn
          |> put_status(:bad_request)
          |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} -> msg end)})
      end
    rescue
      _ -> send_resp(conn, 500, "Internal Server Error")
    end
  end
end
