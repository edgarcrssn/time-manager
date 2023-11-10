defmodule TimeManagerApiWeb.AuthController do
  use TimeManagerApiWeb, :controller
  alias TimeManagerApi.Authentication

  def logout(conn, _params) do
    conn
    |> put_resp_cookie("jwt", "", http_only: true, expires: ~U[1970-01-01T00:00:00Z])
    |> send_resp(204, "")
  end

  def login(conn, %{"username" => username, "password" => password}) do
    case Authentication.authenticate(username, password) do
      {:ok, user} ->
        jwt = Authentication.generate_jwt(user)  # Assuming this just returns a JWT string.
        {:ok, claims} = Joken.peek_claims(jwt)   # Decode the token to get the claims.
        csrf_token = claims["x_csrf_token"]      # Extract the CSRF token from claims.
        conn
        |> put_resp_cookie("jwt", jwt, http_only: true)
        |> json(%{user: user, csrf_token: csrf_token})
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end
end
