# TimeManagerApi

## Requirements

This api is built with the `Phoenix` framework, written in `Elixir`. You'll need to have it installed on your machine. See the official [Phoenix installation guide](https://hexdocs.pm/phoenix/installation.html).

It also uses `PostgreSQL`. See the official [PostgreSQL installation guide](https://wiki.postgresql.org/wiki/Detailed_installation_guides).

You can have a `PostgreSQL` instance running very quickly with a one-line command using `Docker`:
```bash
docker run --name postgres-container -e POSTGRES_USER=your_postgres_user -e POSTGRES_PASSWORD=your_postgres_user_password -p 5432:5432 -d postgres
```

## Installation

Clone the project:
```bash
git clone git@github.com:EpitechMscProPromo2025/T-POO-700-LIL_3.git
```
```bash
cd T-POO-700-LIL_3
```

Create your environment config file:
```bash
touch .env
```

Setup your *.env* file. See [.env.example](.env.example).
Once it's done, run:
```bash
source .env
```

Install dependencies and setup the database:
```bash
mix setup
```

Start the server:
```bash
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser or by using Postman.

## Usefull commands

Create the database (executed by `mix setup`):
```bash
mix ecto.create
```

Apply the migrations (executed by `mix setup`):
```bash
mix ecto.migrate
```

Run the seed to hydrate your database with some data (executed by `mix setup`):
```bash
mix run priv/repo/seeds.exs
```

## Learn more about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
