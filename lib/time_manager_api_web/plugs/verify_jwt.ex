defmodule TimeManagerApiWeb.Plugs.VerifyJWT do
  import Plug.Conn
  alias TimeManagerApi.Authentication

  def init(options), do: options

  def call(conn, _opts) do
    jwt_cookie = get_req_cookie(conn, "jwt")

    with {:ok, claims} <- Authentication.verify_jwt(jwt_cookie),
         {:ok, csrf_token} <- Map.fetch(claims, "x_csrf_token"),
         ["x-csrf-token"] <- get_req_header(conn, "x-csrf-token") do
      if csrf_token == "x-csrf-token" do
        assign(conn, :current_user, claims["sub"])
      else
        conn
        |> send_resp(403, "Forbidden")
        |> halt()
      end
    else
      _ ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end
end
