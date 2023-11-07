defmodule TimeManagerApi.Plugs.Authorization do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts) do
    opts = Keyword.get(opts, :opts, [])
    opts
  end

  def call(conn, opts) do
    if is_authorized?(conn, opts) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{message: "Forbidden"})
      |> halt()
    end
  end

  defp is_authorized?(conn, opts) do
    current_user = conn.assigns.current_user

    cond_1 = current_user.role == "general_manager"

    cond_2 = Enum.member?(opts, "is_manager") && current_user.role == "manager"

    user_id =
      case {conn.params["userID"], conn.params["userId"]} do
        {nil, nil} -> nil
        {user_id, nil} -> String.to_integer(user_id)
        {nil, user_id} -> String.to_integer(user_id)
        {user_id, user_id} -> String.to_integer(user_id)
      end
    cond_3 = Enum.member?(opts, "is_user_himself") && current_user.sub == user_id

    cond_1 || cond_2 || cond_3
  end
end
