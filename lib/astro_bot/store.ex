defmodule AstroBot.Store do
  use GenServer

  @filename "lembretes.json"

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(_) do
    state = load()
    {:ok, state}
  end

  def salvar(user_id, texto) do
    GenServer.call(__MODULE__, {:salvar, user_id, texto})
  end

  def buscar(user_id) do
    GenServer.call(__MODULE__, {:buscar, user_id})
  end

  def handle_call({:salvar, user_id, texto}, _from, state) do
    lista = Map.get(state, user_id, [])
    novo_state = Map.put(state, user_id, lista ++ [texto])
    persistir(novo_state)
    {:reply, :ok, novo_state}
  end

  def handle_call({:buscar, user_id}, _from, state) do
    {:reply, Map.get(state, user_id, []), state}
  end

  defp load do
    case File.read(@filename) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, data} -> data
          _ -> %{}
        end

      {:error, _} ->
        %{}
    end
  end

  defp persistir(state) do
    File.write!(@filename, Jason.encode!(state, pretty: true))
  end
end
