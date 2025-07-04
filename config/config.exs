# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :payment_router,
  ecto_repos: [PaymentRouter.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :payment_router, PaymentRouterWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PaymentRouterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PaymentRouter.PubSub,
  live_view: [signing_salt: "nft56UbU"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :payment_router, App.Repo,
 migration_primary_key: [name: :uuid, type: :binary_id]

# Payment cache service
config :payment_router, cache_service: PaymentRouter.PaymentsCache

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
