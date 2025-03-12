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
        {:ok, resp.body |> Jason.decode! |> Enum.map(fn itil -> %{name: itil["completename"], id: itil["id"]} end) |> Enum.sort(&(&1.name < &2.name))}
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
        {:ok, resp.body |> Jason.decode! |> Enum.map(fn itil -> %{name: itil["name"], id: itil["id"]} end)  |> Enum.sort(&(&1.name < &2.name))}
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

  def list_tickets(session_token) do
    case HTTPoison.get(
      URI.merge(@endpoint, "/apirest.php/Ticket"),
      [
        {"Content-Type", "application/json"},
        {"App-Token", @app_token},
        {"Session-Token", session_token},
      ]
    ) do
      {:ok, resp} ->
        {:ok, resp.body}
      {:error, resp} ->
        {:error, resp}
    end
  end

  def list_tickets() do
    case init_session() do
      {:ok, resp} -> list_tickets(resp["session_token"])
      {:error, resp} -> {:error, resp}
    end
  end

  def list_documents(session_token) do
    case HTTPoison.get(
      URI.merge(@endpoint, "/apirest.php/Document"),
      [
        {"Content-Type", "application/json"},
        {"App-Token", @app_token},
        {"Session-Token", session_token},
      ]
    ) do
      {:ok, resp} ->
        {:ok, resp.body}
      {:error, resp} ->
        {:error, resp}
    end
  end

  def list_documents() do
    case init_session() do
      {:ok, resp} -> list_documents(resp["session_token"])
      {:error, resp} -> {:error, resp}
    end
  end

  def create_ticket(ticket, session_token) do
    email   = ticket["email"]
    itil_id = ticket["itil"]
    loc_id  = ticket["location"]
    content = "Name: #{ticket["name"]}\nRoom: #{ticket["room"]}\n\n#{ticket["content"]}"

    upload_manifest = %{
      "input" => %{
        "_users_id_requester" => 0,
        "_users_id_requester_notif" => %{
          "alternative_email" => [email],
          "use_notification" => 1
        },
        "content" => content,
        "name" => "#{ticket["name"]} | #{ticket["room"]}",
        "itilcategories_id" => itil_id,
        "locations_id" => loc_id
      }
    }

    files =
      (ticket["file"] || [])
      |> Enum.with_index()
      |> Enum.map(fn {file, index} ->
        {:file, file.path, {"form-data", [{"name", "filename[#{index}]"}, {"filename", file.filename}]}, [{"Content-Type", file.content_type}]}
      end)

    {body, content_type} =
      if Enum.empty?(files) do
        {
          Jason.encode!(upload_manifest),
          "application/json"
        }
      else
        {
          {:multipart,
            [
              {"uploadManifest", Jason.encode!(upload_manifest), [{"Content-Type", "application/json"}]}
            ] ++ files
          },
          "multipart/form-data"
        }
      end

    case HTTPoison.post(
      URI.merge(@endpoint, "apirest.php/Ticket"),
      body,
      [
        {"Content-Type", content_type},
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
