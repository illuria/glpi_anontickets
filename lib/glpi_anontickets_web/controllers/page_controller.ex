defmodule GlpiAnonticketsWeb.PageController do
  use GlpiAnonticketsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    text(conn, "nothing to see here...")
  end

  def helpdesk(conn, _params) do
    {:ok, itil_categories} = GlpiAnontickets.list_itil_categories
    {:ok, locations} = GlpiAnontickets.list_locations
    conn
    |> render(:helpdesk, itil_categories: itil_categories, locations: locations)
  end

  def submit(conn, params) do
    GlpiAnontickets.create_ticket(params) |> IO.inspect
    conn
    |> put_resp_header("HX-Push-Url", "/helpdesk")
    |> render(:submitted)
  end
end
