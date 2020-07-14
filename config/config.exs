# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :request_mock,
  namespace: RequestMock,
  ecto_repos: [RequestMock.Repo],
  requests: [
    anonymous: "/tmp/anonymous/requests/",
    authenticated: "not_implemented_yet"
  ],
  responses: [
    anonymous: "/tmp/anonymous/requests/",
    authenticated: "not_implemented_yet"
  ]

# Configures the endpoint
config :request_mock, RequestMock.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VbR39/X9I7jCbdPD788hjbdGhlCVNZos1eyAaVOtRMp5cPrgB+QkdvZ8EqBVwMel",
  render_errors: [view: RequestMock.Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RequestMock.PubSub,
  live_view: [signing_salt: "v0bScE2Q"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
