defmodule Chatbot.Server do
  @moduledoc false
  use Plug.Router
  require Logger
  require IEx
  import Plug.Conn.Query

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [name: :chat_server], [port: 3000]
  end

  get "/" do
    conn
    |> send_resp(200, "ok")
    |> halt
  end

  get "/webhook/384091mucfkldsgfh9p8q2375ur4p98/" do
    # IEx.pry
    query = decode(conn.query_string)
    [status, message] =
      case query["hub.verify_token"] do
        "12" ->
          [200 , query["hub.challenge"]]
        _ ->
          [400 , "Invalid Verify Token, expected: [12], got: [" <> query["hub.verify_token"] <> "]"]
      end
    conn
    |> send_resp(status, message)
    |> halt
  end

  post "/webhook/384091mucfkldsgfh9p8q2375ur4p98/" do
    conn.body_params["entry"]
    |> Enum.each(fn entry ->
      Logger.info('#{entry["id"]} => Received a request!' )
      Enum.each(entry["messaging"], fn messaging_item ->
        Logger.info('#{messaging_item["request_id"]} => Handling Messaging item with sender: #{messaging_item["sender"]["id"]}')
        Chatbot.Client.Supervisor.start_client(messaging_item)
      end)
    end)
    conn
    |> send_resp(200, '')
    |> halt
  end

  match _ do
    Logger.info('No Match!')
    conn
    |> send_resp(404, "oops")
    |> halt
  end
end