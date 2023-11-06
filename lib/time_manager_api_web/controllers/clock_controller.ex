defmodule TimeManagerApiWeb.ClockController do
  use TimeManagerApiWeb, :controller
  import Ecto.Query

  # TODO show: must be "general_manager" or "manager" of the user or user himself
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

  # TODO show: must be "general_manager" or "manager" of the user or user himself
  def getLastClock(conn, %{"userID" => user_id}) when is_binary(user_id) do
    user_id = String.to_integer(user_id)

    try do
      last_clock =
        TimeManagerApi.Repo.one(
          from c in TimeManagerApi.Clock,
          where: c.user_id == ^user_id,
          order_by: [desc: c.id],
          limit: 1
        )

      case last_clock do
        nil ->
          conn
          |> put_status(:not_found)
          |> json(%{"message" => "Clock not found"})
        _ ->
          conn
          |> put_status(:ok)
          |> json(%{clock: last_clock})
      end
    rescue
      exception ->
        IO.inspect(exception, label: "Exception")
        conn
        |> put_status(:internal_server_error)
        |> json(%{"message" => "Internal Server Error"})
    end
  end

  # TODO create: must be user himself or his manager
  def create(conn, %{"userID" => user_id, "clock" => clock_params}) when is_binary(user_id) do
    user_id = String.to_integer(user_id)

    last_clock = TimeManagerApi.Repo.one(from c in TimeManagerApi.Clock, where: c.user_id == ^user_id, order_by: [desc: c.time], limit: 1)

    new_status = case last_clock do
      nil -> true
      %TimeManagerApi.Clock{status: last_status} -> not last_status
    end

    merged_params = Map.merge(clock_params, %{"user_id" => user_id, "status" => new_status})

    changeset = TimeManagerApi.Clock.changeset(%TimeManagerApi.Clock{}, merged_params)

    try do
      case TimeManagerApi.Repo.insert(changeset) do
        {:ok, clock} ->
          conn
          |> put_status(:created)
          |> json(clock)

        {:error, changeset} ->
          conn
          |> put_status(:bad_request)
          |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
      end
    rescue
      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"message" => "Internal Server Error"})
    end
  end

  # TODO create: must be the team manager
  @spec createForMyTeam(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def createForMyTeam(conn, %{"teamID" => team_id, "clock" => clock_params}) when is_binary(team_id) do
    team = TimeManagerApi.Repo.one(from t in TimeManagerApi.Team, where: t.id == ^team_id)

    case team do
      %TimeManagerApi.Team{} = _team ->
        users_in_team_ids = TimeManagerApi.Repo.all(
          from u in TimeManagerApi.User,
          join: ut in TimeManagerApi.UserTeam,
          on: u.id == ut.user_id,
          where: ut.team_id == ^team_id,
          select: u.id
        )

        case users_in_team_ids do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{"message" => "Users Not Found"})

          _ ->
            create_clocks_for_users(conn, users_in_team_ids, clock_params)

            conn
            |> put_status(:created)
            |> json(%{"message" => "Clocks creation started for team users"})
        end

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{"message" => "Team Not Found"})
    end
  end

  defp create_clocks_for_users(conn, user_ids, clock_params) do
    Enum.each(user_ids, fn user_id ->
      Task.start(fn -> create_clock_for_user(conn, user_id, clock_params) end)
    end)
  end

  defp create_clock_for_user(conn, user_id, clock_params) do
    create(conn, %{"userID" => Integer.to_string(user_id), "clock" => clock_params})
  end
end
