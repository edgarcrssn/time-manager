defmodule TimeManagerApiWeb.WorkingtimesController do
  use TimeManagerApiWeb, :controller
  import Plug.Conn

  def getall(conn, %{"userID" => userId}) do
    date_start = conn.query_params["start"]
    date_end = conn.quert_params["end"]
    json(conn,"Id de l'utilisateur #{userId}, date de début : #{date_start}, date de fin : #{date_end}")
  end

  def getone(conn, %{"userId" => userId}, %{"id" => id}) do
    json(conn,"Id de l'utilisateur : #{userId}, id du workingtimes #{id}")
  end

  def create(conn, %{"userId" => userId}) do
    json(conn,"Création du workingtimes, id de l'utilisateur : #{userId}")
  end

  def update(conn, %{"id" => id}) do
    json(conn,"Modification du workingtimes, id du workingtimes : #{id}")
  end

  def delete(conn, %{"id" => id}) do
    json(conn,"Suppression du workingtimes, id du workingtimes : #{id}")
  end
end
