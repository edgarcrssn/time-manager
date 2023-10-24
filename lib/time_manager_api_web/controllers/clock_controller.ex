defmodule TimeManagerApiWeb.ClockController do
  use TimeManagerApiWeb, :controller

  import Ecto.Query

  def show(conn, %{"userID" => user_id}) when is_binary(user_id) do
    user_id = String.to_integer(user_id)
    clocks = TimeManagerApi.Repo.all(from c in TimeManagerApi.Clock, where: c.user_id == ^user_id)
    json(conn, clocks)
  end

  def create(conn, %{"userID" => user_id, "clock" => clock_params}) when is_binary(user_id) do
    user_id = String.to_integer(user_id)
    changeset = TimeManagerApi.Clock.changeset(%TimeManagerApi.Clock{}, Map.merge(clock_params, %{"user_id" => user_id}))

    case TimeManagerApi.Repo.insert(changeset) do
      {:ok, clock} -> json(conn, clock)
      {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} -> msg end)})
    end
  end
end
