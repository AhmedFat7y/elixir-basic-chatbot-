defmodule Chatbot.Client.Supervisor do
  @moduledoc false
  require IEx
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :chatbot_client_supervisor)
  end

  def start_client(messaging_item) do
    IO.puts "MessagingItem #{Poison.encode!(messaging_item)}"
#    IEx.pry
    child_name = try do
      IO.puts('Atom: #{messaging_item["sender"]["id"]} already exists!')
      String.to_existing_atom(messaging_item["sender"]["id"])
    rescue
      ArgumentError ->
        IO.puts('Atom: #{messaging_item["sender"]["id"]} Doesnt exist! Creating New One')
        String.to_atom(messaging_item["sender"]["id"])
    end
    IO.puts('Atom is: #{child_name}')
    pid = Process.whereis(child_name)
    unless pid && Process.alive?(pid) do
      IO.puts('Process #{child_name} || #{pid} is not alive! Starting new one')
      Supervisor.start_child(:chatbot_client_supervisor, [[], [name: child_name]])
    end
    Chatbot.Client.process_message(child_name, {:messaging_item, messaging_item})
  end

  def init([]) do
    children = [
      worker(Chatbot.Client, [], restart: :transient)
    ]
#    String.to_existing_atom()
    supervise(children, strategy: :simple_one_for_one)
  end
end