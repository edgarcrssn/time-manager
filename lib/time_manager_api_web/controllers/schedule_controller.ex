defmodule TimeManagerApiWeb.EmployeeScheduleController do
  use TimeManagerApiWeb, :controller
  import Ecto.Query

  @doc """
  Retrieve the schedule for a specific user.
  """
  def index(conn, %{"userID" => user_id}) do
    schedule = TimeManagerApi.Repo.get(TimeManagerApi.EmployeeSchedule, user_id)

    case schedule do
      %TimeManagerApi.EmployeeSchedule{} = schedule ->
        json(conn, schedule)

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Schedule for user with id #{user_id} does not exist"})
    end
  end

  @doc """
  Create a new schedule for a specific user.
  """
  def create(conn, %{"userID" => user_id, "schedule" => schedule_params}) do
    existing_schedule = TimeManagerApi.Repo.get_by(TimeManagerApi.EmployeeSchedule, user_id: user_id)

    case existing_schedule do
      nil ->
        params_with_user = Map.put(schedule_params, "user_id", user_id)
        changeset = TimeManagerApi.EmployeeSchedule.changeset(%TimeManagerApi.EmployeeSchedule{}, params_with_user)

        case TimeManagerApi.Repo.insert(changeset) do
          {:ok, schedule} ->
            conn
            |> put_status(:created)
            |> json(%{schedule: schedule})

          {:error, changeset} ->
            conn
            |> put_status(:bad_request)
            |> json(%{message: "Bad Request", errors: changeset.errors})
        end

      %TimeManagerApi.EmployeeSchedule{} ->
        conn
        |> put_status(:conflict) # 409 Conflict
        |> json(%{error: "Schedule for user with id #{user_id} already exists"})
    end
  end


  @doc """
Update a specific schedule by its ID.
"""
def update(conn, %{"userID" => user_id, "schedule" => schedule_params}) do
  schedule = TimeManagerApi.Repo.get(TimeManagerApi.EmployeeSchedule, user_id)

  case schedule do
    nil ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "Schedule not found"})

    _ ->
      changeset = TimeManagerApi.EmployeeSchedule.changeset(schedule, schedule_params)
      case TimeManagerApi.Repo.update(changeset) do
        {:ok, updated_schedule} ->
          json(conn, %{schedule: updated_schedule})

        {:error, changeset} ->
          conn
          |> put_status(:bad_request)
          |> json(%{message: "Bad Request", errors: changeset.errors})
      end
  end
end


@doc """
Delete a specific schedule by its ID.
"""
# TODO delete: must be authenticated
def delete(conn, %{"userID" => _user_id, "id" => id}) do
  schedule = TimeManagerApi.Repo.get(TimeManagerApi.EmployeeSchedule, id)

  case schedule do
    %TimeManagerApi.EmployeeSchedule{} = schedule ->
      {:ok, _} = TimeManagerApi.Repo.delete(schedule)
      json(conn, %{message: "Schedule deleted successfully"})

    nil ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "Schedule with id #{id} does not exist"})
  end
end

end
