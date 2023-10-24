defmodule TimeManagerApiWeb.WorkingtimesController do
  use TimeManagerApiWeb, :controller
  import Plug.Conn
  import TimeManagerApiWeb.WorkingtimesService

  def getall(conn, %{"userID" => userId}) do
    date_start = conn.query_params["start"]
    date_end = conn.query_params["end"]
    IO.inspect("Date de début : #{date_start}")
    IO.inspect("Date de fin #{date_end}")

    # check if the start and end parameter exist
    case date_start == nil || date_end == nil do
      true ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "The parameters for this request are missing"})
      false -> {
        # continue
        case validate_format(date_start) do
          true ->
            {
              # continue
              case validate_format(date_end) do
                true -> {
                  # continue
                  json(conn,"Id de l'utilisateur #{userId}, date de début : #{date_start}, date de fin : #{date_end}")
                }
                false -> {
                  conn
                  |> put_status(:bad_request)
                  |> json(%{error: "The end parameter is not in the good format"})
                }
              end
            }
          false ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "The start parameter is not in the good format"})
        end
      }
    end
  end

  def getone(conn, %{"userID" => userId, "id" => id}) do
    json(conn,"Id de l'utiyisateur : #{userId}, id du workingtimes #{id}")
  end

  def create(conn, %{"userID" => userId}) do
    json(conn,"Création du workingtimes, id de l'utilisateur : #{userId}")
  end

  def update(conn, %{"id" => id}) do
    json(conn,"Modification du workingtimes, id du workingtimes : #{id}")
  end

  def delete(conn, %{"id" => id}) do
    json(conn,"Suppression du workingtimes, id du workingtimes : #{id}")
  end
end
