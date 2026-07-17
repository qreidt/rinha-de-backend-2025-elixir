# Dockerfile for Rinha de Backend 2025 (Elixir)
# Multi-stage build for minimal image size and performance

# --- Build Stage ---
FROM hexpm/elixir:1.16.2-erlang-26.2.4-alpine-3.19.1 AS build

# Install build dependencies
RUN apk add --no-cache build-base git npm

# Set build env vars
ENV MIX_ENV=prod

WORKDIR /app

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files and install deps
COPY mix.exs mix.lock ./
COPY config ./config
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy source code
COPY lib ./lib
COPY priv ./priv

# Compile project
RUN mix compile

# Build assets (if any)
# Uncomment if using assets
# COPY assets ./assets
# RUN cd assets && npm install && npm run deploy
# RUN mix phx.digest

# Release
RUN mix release

# --- Runtime Stage ---
FROM alpine:3.19.1 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs bash postgresql-client

WORKDIR /app

# Copy release from build
COPY --from=build /app/_build/prod/rel/payment_router ./_build/prod/rel/payment_router

ENV RELEASE_COOKIE "supersecretcookie1234567890"

# Expose HTTP port
EXPOSE 9999
EXPOSE 4369

# Start Phoenix release
CMD ["sh", "-c", "_build/prod/rel/payment_router/bin/payment_router start"]
