defmodule AstroBot.Application do
  use Application

  def start(_type, _args) do
    children = [
      AstroBot.Consumer,
      AstroBot.Store
    ]

    opts = [strategy: :one_for_one, name: AstroBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
