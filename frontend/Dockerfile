FROM ghcr.io/gleam-lang/gleam:v1.18.0-erlang-alpine AS builder

RUN apk add --no-cache curl tar bash

WORKDIR /app

COPY gleam.toml manifest.toml ./
RUN gleam deps download

COPY . .

RUN gleam run -m lustre/dev build frontend --minify

FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/dist /srv
