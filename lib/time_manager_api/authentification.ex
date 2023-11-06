defmodule TimeManagerApi.Authentication do
  alias Joken
  alias TimeManagerApi.User
  alias TimeManagerApi.Repo

  @secret_key Base.decode64!(System.get_env("SECRET_KEY") || "gOMpGaeAABvAJW8pX8ggwwQx+9/7uj38I98VHl4K9Ec=")

  def authenticate(username, password) do
    user = Repo.get_by(User, username: username)

    if user && Argon2.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_credentials}
    end
  end

  def generate_jwt(user) do
    claims = %{sub: user.id}
    csrf_token = generate_csrf_token()
    claims = Map.put(claims, "x_csrf_token", csrf_token)

    signer = Joken.Signer.create("HS256", @secret_key)

    case Joken.encode_and_sign(claims, signer) do
      {:ok, token, _claims} -> token
      {:error, _reason} -> :error
    end
  end


  defp generate_csrf_token do
    :crypto.strong_rand_bytes(16)
    |> Base.encode64()
  end

  def verify_jwt(nil), do: {:error, :token_not_provided}

  def verify_jwt(token) do
    signer = Joken.Signer.create("HS256", @secret_key)
    case Joken.verify(token, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, _reason} -> {:error, :invalid_token}
    end
  end

end
