defmodule AstroBot.Consumer do
  use Nostrum.Consumer
  alias AstroBot.Commands

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    if !msg.author.bot && String.starts_with?(msg.content, "!") do
      msg.content
      |> String.slice(1..-1//1)
      |> String.split(" ")
      |> parse_command(msg)
    end
  end

  def handle_event(_event), do: :noop

  defp parse_command([cmd | args], msg) do
    Commands.handle(String.downcase(cmd), args, msg)
  end
end
