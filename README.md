# GlpiAnontickets

This is a web application that allows you to submit tickets to GLPI via the REST API.

A proper documentation is needed, but for now, don't forget to set the following environment variables:

  * `GLPI_ANONTICKET_ENDPOINT`
  * `GLPI_ANONTICKET_APP_TOKEN`
  * `GLPI_ANONTICKET_AUTH_TOKEN`

Optionally, you can also set:

  * `GLPI_ANONTICKET_NAME`
  * `GLPI_ANONTICKET_ICON`
  * `GLPI_ANONTICKET_LOCALE`


To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
