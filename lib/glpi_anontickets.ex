defmodule GlpiAnontickets do
  @moduledoc """
  GlpiAnontickets keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @endpoint   Application.get_env(:glpi_anontickets, GlpiAnontickets)[:endpoint]
  @app_token  Application.get_env(:glpi_anontickets, GlpiAnontickets)[:app_token]
  @auth_token Application.get_env(:glpi_anontickets, GlpiAnontickets)[:auth_token]
  defp init_session() do
    case HTTPoison.get(
      URI.merge(@endpoint, "/apirest.php/initSession"),
      [
        {"Content-Type", "application/json"},
        {"App-Token", @app_token},
        {"Authorization", "user_token " <> @auth_token},
      ]
    ) do
      {:ok, resp} -> {:ok, resp.body |> Jason.decode!}
      {:error, resp} -> {:error, resp}
    end
  end

  def list_itil_categories(session_token) do
    case HTTPoison.get(
      URI.merge(@endpoint, "/apirest.php/itilcategory"),
      [
        {"Content-Type", "application/json"},
        {"App-Token", @app_token},
        {"Session-Token", session_token},
      ]
    ) do
      {:ok, resp} ->
        {:ok, resp.body |> Jason.decode! |> Enum.map(fn itil -> %{name: itil["completename"], id: itil["id"]} end)}
      {:error, resp} ->
        {:error, resp}
    end
  end

  def list_itil_categories() do
    case init_session() do
      {:ok, resp} -> list_itil_categories(resp["session_token"])
      {:error, resp} -> {:error, resp}
    end
  end

  def list_locations(session_token) do
    case HTTPoison.get(
      URI.merge(@endpoint, "/apirest.php/location"),
      [
        {"Content-Type", "application/json"},
        {"App-Token", @app_token},
        {"Session-Token", session_token},
      ]
    ) do
      {:ok, resp} ->
        {:ok, resp.body |> Jason.decode! |> Enum.map(fn itil -> %{name: itil["completename"], id: itil["id"]} end)}
      {:error, resp} ->
        {:error, resp}
    end
  end

  def list_locations() do
    case init_session() do
      {:ok, resp} -> list_locations(resp["session_token"])
      {:error, resp} -> {:error, resp}
    end
  end

  def create_ticket(ticket, session_token) do
    body = %{
      "input" => %{
        "_users_id_requester" => 0,
        "_users_id_requester_notif" => %{
          "alternative_email" => [ticket["email"]],
          "use_notification" => 1
        },
        "content" => ticket["content"],
        "name" => "",
        "itilcategories_id" => ticket["itil"],
        "locations_id" => ticket["location"]
      }
    }
    case HTTPoison.post(
      URI.merge(@endpoint, "apirest.php/Ticket"),
      Jason.encode!(body),
      [
        {"Content-Type", "application/json"},
        {"App-Token", @app_token},
        {"Session-Token", session_token},
      ]
    ) do
      {:ok, resp} -> {:ok, resp}
      {:error, resp} -> {:error, resp}
    end
  end

  def create_ticket(ticket) do
    case init_session() do
      {:ok, resp} -> create_ticket(ticket, resp["session_token"])
      {:error, resp} -> {:error, resp}
    end
  end
end
