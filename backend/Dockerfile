FROM erlang:28.0.2.0-alpine AS build
RUN apk add --no-cache watchexec
COPY --from=ghcr.io/gleam-lang/gleam:v1.18.0-erlang-alpine /bin/gleam /bin/gleam
COPY . /app/
RUN cd /app && gleam export erlang-shipment

FROM erlang:28.0.2.0-alpine
RUN \
  addgroup --system webapp && \
  adduser --system webapp -g webapp
USER webapp
COPY --from=build /app/build/erlang-shipment /app
WORKDIR /app
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
CMD ["run"]
