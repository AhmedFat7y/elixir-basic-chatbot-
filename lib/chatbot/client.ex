defmodule Chatbot.Client do
  @moduledoc false
  use GenServer

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def process_message(name, messaging_item) do
  IO.puts "Calling The Process now to handle mesage item"
    GenServer.call(name, messaging_item)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:messaging_item, messaging_item}, _from, state) do
    IO.puts 'Messagin Item From #{messaging_item["sender"]["id"]} is: #{Poison.encode!(messaging_item)}'
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end