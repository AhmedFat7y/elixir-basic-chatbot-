defmodule Api.Messenger.Base do
  @moduledoc false
  use HTTPotion.Base
  @config %{
    protocol: "https",
    host: "graph.facebook.com",
  }
  defstruct [:sender, :recipient, :timestamp, :postback]

  def prepend_protocol(url) do
    @config.protocol <> "://" <> url
    |> IO.inspect
  end

  def process_url(url) do
    @config.host <> url
    |> IO.inspect
  end

  def process_request_headers(headers) do
    headers
    |> Dict.put(:"Accept", "*/*")
    |> Dict.put(:"Content-Type", "application/json")
    |> Dict.put(:"User-Agent", "messenger-bot")
  end

  def process_response_body(body) do
    body
    |> IO.inspect
    |> IO.iodata_to_binary
    |> Poison.decode()
  end

  def process_request_body(body) do
    body
    |> IO.inspect
  end
end

defmodule Api.Messenger do
  require IEx

  @config %{
    page_access_token: "EAAM500J0ZBGMBAAiP5ZB7rXxZCiryaRjjTfFsVDuixYZCSPBSnKDajGRJVzWV0m2uXd9dtjkACufpNCGACIux3nT5fsIpJJyTWPhVkgexeNiZBbV9n3xeoZAeSt60WEnFr24rmV2wbm0xByATyKDb1tajZBgLDFt9qJqaCyTOrJhAZDZD",
    messages_url: '/v2.6/me/messages',
  }

  def post_request(url, body) do
    options = [query: %{access_token: @config.page_access_token}, body: body]
    Api.Messenger.Base.post(url, options)
  end

  def handle(messaging_list) do
    messaging_list
    |> Enum.each(fn messaging_item ->
      sender = messaging_item["sender"]["id"]
      text = messaging_item["message"]["text"]
      mark_seen(sender)
      send_message(sender, text)
    end)
  end

  def mark_seen(sender) do
    {_, body} = Poison.encode(%{"recipient": %{"id": "#{sender}"}, "sender_action": "mark_seen"})
    post_request(@config.messages_url, body)
  end

  def send_message(sender, text) do
    {_, body} = Poison.encode(%{"recipient": %{"id": "#{sender}"},"message": %{"text": "#{text}"}})
    post_request @config.messages_url, body
  end
end