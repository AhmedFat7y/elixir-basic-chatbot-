defmodule Chatbot.Client do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def process_message(name, messaging_item) do
    {_, messaging_item_data} = messaging_item
    Logger.info '#{messaging_item_data["request_id"]} => Calling The #{name} Process now to handle mesage item'
    try do
      GenServer.cast(name, messaging_item)
    rescue
      e -> Logger.error('#{messaging_item_data["request_id"]} => #{inspect e}')
    end
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_cast({:messaging_item, messaging_item}, state) do
    Logger.info '#{messaging_item["request_id"]} => Processing Messagin Item From #{messaging_item["sender"]["id"]}'
    :timer.sleep(:rand.uniform(10) * 100)
    Logger.info '#{messaging_item["request_id"]} => Done #{messaging_item["sender"]["id"]}'
    {:noreply, state}
  end

#  def handle_cast(_msg, state) do
#    {:noreply, state}
#  end
end