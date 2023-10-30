FROM elixir:1.15

RUN apt-get update && apt-get install -y postgresql-client inotify-tools

WORKDIR /app
COPY . .

RUN mix local.hex --force

RUN mix deps.get
RUN mix deps.compile

COPY ./entrypoint.sh /app/
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]