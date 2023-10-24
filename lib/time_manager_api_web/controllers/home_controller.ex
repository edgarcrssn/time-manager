defmodule TimeManagerApiWeb.HomeController do
  use TimeManagerApiWeb, :controller

  def index(conn, _params) do
    content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>TimeManager API</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                text-align: center;
                margin-top: 50px;
            }
            a {
                color: #3498db;
                text-decoration: none;
                margin: 0 10px;
            }
            a:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <h1>Welcome to TimeManager API!</h1>
        <p>
            <a href="/api/users">Users</a>
            <a href="/api/clocks/1">Clocks</a>
            <a href="/api/workingtimes/1">Working times</a>
        </p>
    </body>
    </html>
    """
    send_resp(conn, 200, content)
  end
end
