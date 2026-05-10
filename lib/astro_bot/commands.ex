defmodule AstroBot.Commands do
  alias AstroBot.Store

  # Sem parâmetro - !ping
  def handle("ping", _args, msg) do
    Nostrum.Api.create_message(msg.channel_id, "Pong! Bot online e funcionando!")
  end

  # Um parâmetro - !cachorro
  def handle("cachorro", _args, msg) do
    case HTTPoison.get("https://dog.ceo/api/breeds/image/random") do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        url = data["message"]
        Nostrum.Api.create_message(msg.channel_id, url)

      _ ->
        Nostrum.Api.create_message(msg.channel_id, "Erro ao buscar foto de cachorro.")
    end
  end

  # Um parâmetro - !anime <nome>
  def handle("anime", args, msg) do
    nome = args |> Enum.join("%20")

    case HTTPoison.get("https://api.jikan.moe/v4/anime?q=#{nome}&limit=1") do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        anime = data["data"] |> List.first()

        if anime do
          resposta = """
          **#{anime["title"]}**
          Episodios: #{anime["episodes"] || "?"}
          Nota: #{anime["score"] || "?"}
          Status: #{anime["status"]}
          Sinopse: #{String.slice(anime["synopsis"] || "", 0, 200)}...
          """

          Nostrum.Api.create_message(msg.channel_id, resposta)
        else
          Nostrum.Api.create_message(msg.channel_id, "Anime nao encontrado.")
        end

      _ ->
        Nostrum.Api.create_message(msg.channel_id, "Erro ao buscar anime.")
    end
  end

  # Dois parâmetros - !conv <valor> <moeda_origem> <moeda_destino>
  def handle("conv", [valor, origem, destino | _], msg) do
    case HTTPoison.get("https://open.er-api.com/v6/latest/#{String.upcase(origem)}") do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        taxa = data["rates"][String.upcase(destino)]

        if taxa do
          {num, _} = Float.parse(valor)
          resultado = Float.round(num * taxa, 2)

          Nostrum.Api.create_message(
            msg.channel_id,
            "#{valor} #{String.upcase(origem)} = **#{resultado} #{String.upcase(destino)}**"
          )
        else
          Nostrum.Api.create_message(msg.channel_id, "Moeda de destino invalida.")
        end

      _ ->
        Nostrum.Api.create_message(msg.channel_id, "Erro ao converter moeda.")
    end
  end

  # Dois parâmetros - !traducao <idioma> <texto>
  def handle("traducao", [idioma | resto], msg) do
    texto = Enum.join(resto, " ")

    url = "https://api.mymemory.translated.net/get?q=#{URI.encode(texto)}&langpair=pt|#{idioma}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        traduzido = data["responseData"]["translatedText"]
        Nostrum.Api.create_message(msg.channel_id, "Traducao (pt -> #{idioma}): **#{traduzido}**")

      _ ->
        Nostrum.Api.create_message(msg.channel_id, "Erro ao traduzir.")
    end
  end

  # Persistência - !lembrar <texto>
  def handle("lembrar", args, msg) do
    texto = Enum.join(args, " ")
    user_id = to_string(msg.author.id)
    Store.salvar(user_id, texto)
    Nostrum.Api.create_message(msg.channel_id, "Anotado! Vou me lembrar disso!")
  end

  # Persistência - !lembretes
  def handle("lembretes", _args, msg) do
    user_id = to_string(msg.author.id)
    lista = Store.buscar(user_id)

    resposta =
      case lista do
        [] ->
          "Voce nao tem lembretes salvos."

        items ->
          itens_formatados =
            items
            |> Enum.with_index(1)
            |> Enum.map(fn {item, i} -> "#{i}. #{item}" end)
            |> Enum.join("\n")

          "Seus lembretes:\n#{itens_formatados}"
      end

    Nostrum.Api.create_message(msg.channel_id, resposta)
  end

  # Combina duas APIs - !curiosidade <numero>
  def handle("curiosidade", args, msg) do
    numero = args |> Enum.join("") |> String.trim()

    numero = if numero == "", do: "42", else: numero

    case HTTPoison.get("https://uselessfacts.jsph.pl/api/v2/facts/random?language=en") do
      {:ok, %{status_code: 200, body: body}} ->
        fato = Jason.decode!(body)["text"]

        case HTTPoison.get("https://pt.wikipedia.org/api/rest_v1/page/summary/#{numero}") do
          {:ok, %{status_code: 200, body: wiki_body}} ->
            wiki = Jason.decode!(wiki_body)
            resumo = wiki["extract"] || "Sem informacao adicional."

            resposta = """
            **Curiosidade aleatoria:**
            #{fato}

            **Wikipedia sobre #{numero}:**
            #{String.slice(resumo, 0, 300)}...
            """

            Nostrum.Api.create_message(msg.channel_id, resposta)

          _ ->
            Nostrum.Api.create_message(msg.channel_id, "**Curiosidade:** #{fato}")
        end

      _ ->
        Nostrum.Api.create_message(msg.channel_id, "Erro ao buscar curiosidade.")
    end
  end

  def handle("gemini", args, msg) do
    texto = Enum.join(args, " ")

    if texto == "" do
      Nostrum.Api.create_message(msg.channel_id, "Uso: !gemini <pergunta>")
    else
      api_key = System.get_env("GEMINI_KEY")

      url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=#{api_key}"

      body =
        Jason.encode!(%{
          "contents" => [
            %{
              "parts" => [%{"text" => texto}]
            }
          ]
        })

      case HTTPoison.post(url, body, [{"Content-Type", "application/json"}]) do
        {:ok, %{status_code: 200, body: resp}} ->
          data = Jason.decode!(resp)

          resposta =
            data["candidates"]
            |> List.first()
            |> get_in(["content", "parts"])
            |> List.first()
            |> Map.get("text")

          Nostrum.Api.create_message(msg.channel_id, resposta)

        {:ok, %{status_code: status, body: resp}} ->
          IO.puts("Gemini erro status: #{status} - #{resp}")
          Nostrum.Api.create_message(msg.channel_id, "Erro #{status} ao consultar o Gemini.")

        {:error, erro} ->
          IO.puts("Gemini erro HTTP: #{inspect(erro)}")
          Nostrum.Api.create_message(msg.channel_id, "Erro de conexao com o Gemini.")
      end
    end
  end

  def handle(cmd, _args, msg) do
    Nostrum.Api.create_message(
      msg.channel_id,
      "Comando `!#{cmd}` nao reconhecido. Use !ping para testar."
    )
  end
end
