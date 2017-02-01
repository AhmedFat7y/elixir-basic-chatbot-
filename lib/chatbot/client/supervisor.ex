defmodule Chatbot.Client.Supervisor do
  @moduledoc false
  require IEx
  require Logger
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :chatbot_client_supervisor)
  end

  def start_client(messaging_item) do
#    IEx.pry
    child_name = try do
      String.to_existing_atom(messaging_item["sender"]["id"])
      Logger.info('#{messaging_item["request_id"]} => Atom: #{messaging_item["sender"]["id"]} already exists!')
    rescue
      ArgumentError ->
        Logger.info('#{messaging_item["request_id"]} => Atom: #{messaging_item["sender"]["id"]} Doesnt exist! Creating New One')
        String.to_atom(String.Chars.to_string('user_#{messaging_item["sender"]["id"]}'))
    end
    Logger.info('#{messaging_item["request_id"]} => Atom is: #{child_name}')
    pid = Process.whereis(child_name)
    unless pid && Process.alive?(pid) do
      Logger.info('#{messaging_item["request_id"]} => Process #{child_name} || #{pid} is not alive! Starting new one')
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