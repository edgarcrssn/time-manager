defmodule TimeManagerApiWeb.Plugs.VerifyJWT do
  import Plug.Conn
  alias TimeManagerApi.Authentication

  @default_jwt_cookie "jwt"
  @default_csrf_header "x-csrf-token"

  def init(opts) do
    Keyword.merge(opts, jwt_cookie: @default_jwt_cookie, csrf_header: @default_csrf_header)
  end

  def call(conn, opts) do
    jwt_cookie = conn.req_cookies[opts[:jwt_cookie]]
    csrf_header = List.first(get_req_header(conn, opts[:csrf_header]))

    case Authentication.verify_jwt(jwt_cookie) do
      {:ok, claims} -> verify_csrf_token(conn, claims, csrf_header)
      {:error, _error} -> unauthorized_response(conn)
    end
  end

  defp verify_csrf_token(conn, claims, csrf_header) do
    case Map.fetch(claims, "x_csrf_token") do
      {:ok, csrf_token} when csrf_token == csrf_header ->
        assign(conn, :current_user, claims["sub"])
      {:ok, _csrf_token} ->
        forbidden_response(conn, "CSRF token mismatch")
      :error ->
        forbidden_response(conn, "CSRF token missing")
    end
  end

  defp forbidden_response(conn, reason) do
    conn
    |> send_resp(403, "Forbidden: #{reason}")
    |> halt()
  end

  defp unauthorized_response(conn) do
    conn
    |> send_resp(401, "Unauthorized")
    |> halt()
  end
end
