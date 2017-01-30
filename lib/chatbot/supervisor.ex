defmodule Chatbot.Supervisor do
  @moduledoc false
  
  use Supervisor

  def start_link(arg \\ []) do
    Supervisor.start_link(__MODULE__, arg, name: :chatbot_supervisor)
  end

  def init(arg \\ []) do
    children = [
      worker(Chatbot.Client.Supervisor, [], restart: :permanent),
      worker(Chatbot.Server, [], restart: :permanent)
    ]
#    String.to_existing_atom()
    supervise(children, strategy: :one_for_one)
  end
end