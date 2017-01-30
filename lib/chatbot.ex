defmodule Chatbot do
  use Application

  def start(_type, _args) do
    Chatbot.Supervisor.start_link
  end
end
