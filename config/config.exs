# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

app_token     = System.get_env("GLPI_ANONTICKET_APP_TOKEN")  || raise "GLPI_ANONTICKET_APP_TOKEN is not set..."
auth_token    = System.get_env("GLPI_ANONTICKET_AUTH_TOKEN") || raise "GLPI_ANONTICKET_AUTH_TOKEN is not set..."
glpi_endpoint = System.get_env("GLPI_ANONTICKET_ENDPOINT")   || raise "GLPI_ANONTICKET_ENDPOINT is not set..."

config :glpi_anontickets,
  generators: [timestamp_type: :utc_datetime]

config :glpi_anontickets, GlpiAnontickets,
  icon: System.get_env("GLPI_ANONTICKET_ICON") || "logo.svg",
  name: System.get_env("GLPI_ANONTICKET_NAME") || "illuria Tickets Manager",
  endpoint: glpi_endpoint,
  app_token:  app_token,
  auth_token: auth_token


config :glpi_anontickets, GlpiAnonticketsWeb.Gettext,
  default_locale: System.get_env("GLPI_ANONTICKET_LOCALE") || "en",
  locales: ~w(en hy)

# Configures the endpoint
config :glpi_anontickets, GlpiAnonticketsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GlpiAnonticketsWeb.ErrorHTML, json: GlpiAnonticketsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GlpiAnontickets.PubSub,
  live_view: [signing_salt: "1AR+sdAD"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  glpi_anontickets: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  glpi_anontickets: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
