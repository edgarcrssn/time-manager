defmodule TimeManagerApiWeb.WorkingtimesController do
  use TimeManagerApiWeb, :controller
  import Plug.Conn
  import Ecto.Query

  def getall(conn, %{"userID" => userId, "end" => date_end, "start" => date_start}) do
    case {date_end,date_start} do
      {nil,nil} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Bad request occured"})
      {nil,_} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Bad request occured"})
      {_,nil} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Bad request occured"})
      {_,_} ->
        query = from(
          w in TimeManagerApi.Workingtimes,
          where: w.start >= ^"2024-10-25 08:45:51" and w.end <= ^"2025-10-25 08:45:51",
          select: w
        )
        workingtime_result = TimeManagerApi.Repo.all(query)
        json(conn,workingtime_result)
    end
  end

  def getone(conn, %{"userID" => userId, "id" => id} = params) when is_map(params) do
    query =
      from(
        w in TimeManagerApi.Workingtimes,
        where: w.id == ^id and w.user_id == ^userId,
        select: [w.id, w.start, w.end, w.user_id]
      )
      workingtime = TimeManagerApi.Repo.get(TimeManagerApi.Workingtimes,id)
      case workingtime do
        workingtime ->
          json(conn,workingtime)
        nil ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "Workingtime with the id #{id} and the userId #{userId} doesn't exist"})
      end
    json(conn,workingtime)
  end

  def create(conn, %{"userID" => userId, "workingtime" => workingtime_param}) when is_binary(userId) do
    user_id = String.to_integer(userId)
    user = TimeManagerApi.Repo.get(TimeManagerApi.User,userId)
    case user do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
      _ ->
        merged_params = Map.put(workingtime_param,"user_id",user_id)
        changeset = TimeManagerApi.Workingtimes.changeset(%TimeManagerApi.Workingtimes{}, merged_params)
        try do
          case TimeManagerApi.Repo.insert(changeset) do
            {:ok, workingtime} ->
              conn
              |> put_status(:created)
              |> json(%{message: "Workingtime correctly created"})
            {:error, changeset} ->
              conn
              |> put_status(:bad_request)
              |> json(%{error: "Bad request occured"})
          end
        rescue
          _ ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Internal server error"})
        end
    end
  end

  def update(conn, %{"id" => id, "workingtime" => workingtime_param}) do
    workingtime = TimeManagerApi.Repo.get(TimeManagerApi.Workingtimes,id)
    case workingtime do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Workingtime not found"})
      _ ->
        user_id = Map.get(workingtime_param,"user_id")
        user = TimeManagerApi.Repo.get(TimeManagerApi.User,user_id)
        case user do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "User not found"})
          _ ->
            workingtime = TimeManagerApi.Repo.get(TimeManagerApi.Workingtimes,id)
            case workingtime do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{message: "Workingtime not found"})
              _ ->
                changeset = TimeManagerApi.Workingtimes.changeset(workingtime,workingtime_param)
                case TimeManagerApi.Repo.update(changeset) do
                  {:ok, updated_workingtime} ->
                    conn
                    |> put_status(:ok)
                    |> json(%{user: updated_workingtime})

                  {:error, changeset} ->
                    conn
                    |> put_status(:bad_request)
                    |> json(%{message: "Bad request occured"})
                end
            end
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    workingtime = TimeManagerApi.Repo.get(TimeManagerApi.Workingtimes, id)

    case workingtime do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Workingtime not found"})
      _ ->
        case TimeManagerApi.Repo.delete(workingtime) do
          {:ok,_} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "Workingtime deleted"})

          _ ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{message: "Failed to delete workingtime"})
        end
    end
  end

  def convert_to_naive_datetime(date_string) do
    reformatted_date_string = reformat_date(date_string)

    case NaiveDateTime.from_iso8601(reformatted_date_string) do
      {:ok, naive_datetime} ->
        {:ok, naive_datetime}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp reformat_date(date_string) do
    [date_part, time_part] = String.split(date_string,"T")
    [year, month, day] = String.split(date_part, "-")
    [hour, minute, second] = String.split(Enum.at(String.split(time_part, " "), 0), ":")
    reformatted_date = "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}"
    reformatted_date
  end
end
