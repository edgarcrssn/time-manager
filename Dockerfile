FROM elixir:1.15

RUN apt-get update && apt-get install -y postgresql-client inotify-tools

WORKDIR /app
COPY entrypoint.sh /app/
COPY . .

RUN mix local.hex --force

RUN mix deps.get
RUN mix deps.compile

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]