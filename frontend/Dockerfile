FROM ghcr.io/gleam-lang/gleam:v1.18.0-erlang-alpine AS builder

RUN apk add --no-cache curl tar bash

WORKDIR /app

# Copy the shared package and frontend package
COPY shared /app/shared
COPY frontend /app/frontend

WORKDIR /app/frontend
RUN gleam deps download
RUN gleam run -m lustre/dev build frontend --minify

FROM caddy:2-alpine

COPY frontend/Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/frontend/dist /srv
