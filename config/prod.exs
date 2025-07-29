import Config

port = String.to_integer(System.get_env("PORT") || "9999")

# Do not print debug messages in production
config :logger, level: :info


# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
