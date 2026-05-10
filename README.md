# AstroBot

Bot para Discord desenvolvido em Elixir utilizando o framework Nostrum. Implementa nove comandos funcionais consumindo APIs REST diferentes, com persistência de dados em JSON e integração com inteligência artificial.

---

## Indice

- [Requisitos](#requisitos)
- [Instalacao](#instalacao)
- [Configuracao do Token](#configuracao-do-token)
- [Como Executar](#como-executar)
- [Comandos](#comandos)
- [Exemplos de Uso](#exemplos-de-uso)
- [Persistencia de Dados](#persistencia-de-dados)
- [Arquitetura](#arquitetura)
- [APIs Utilizadas](#apis-utilizadas)
- [Conceitos Funcionais](#conceitos-funcionais)

---

## Requisitos

- [Elixir](https://elixir-lang.org/install.html) >= 1.14
- Mix (incluido com o Elixir)
- Token de bot do Discord (Discord Developer Portal)
- Chave de API do Google Gemini (Google AI Studio)

---

## Instalacao

```bash
# Clone o repositorio
git clone <url-do-repositorio>

# Entre na pasta do projeto
cd astro_bot

# Instale as dependencias
mix deps.get
```

---

## Configuracao do Token

O token do bot e a chave do Gemini nao podem aparecer no codigo. Utilize variaveis de ambiente antes de executar:

**Windows (cmd):**
```cmd
set DISCORD_TOKEN=seu_token_do_discord
set GEMINI_KEY=sua_chave_do_gemini
```

**Linux/Mac:**
```bash
export DISCORD_TOKEN=seu_token_do_discord
export GEMINI_KEY=sua_chave_do_gemini
```

### Como obter o token do Discord

1. Acesse [discord.com/developers/applications](https://discord.com/developers/applications)
2. Crie um novo aplicativo e va em **Bot**
3. Clique em **Reset Token** e copie o token
4. Ative os tres **Privileged Gateway Intents**: Presence, Server Members e Message Content
5. Em **OAuth2 > URL Generator**, marque **bot** e as permissoes necessarias
6. Use a URL gerada para adicionar o bot ao seu servidor

### Como obter a chave do Gemini

1. Acesse [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Clique em **Criar chave de API**
3. Selecione o projeto e copie a chave gerada

---

## Como Executar

```cmd
set DISCORD_TOKEN=seu_token_do_discord
set GEMINI_KEY=sua_chave_do_gemini
mix run --no-halt
```

Quando aparecer `[info] READY` no terminal, o bot esta online e pronto para receber comandos.

---

## Comandos

| Comando | Tipo | Descricao |
|---------|------|-----------|
| `!ping` | Sem parametro | Verifica se o bot esta online |
| `!cachorro` | Sem parametro | Envia uma foto aleatoria de cachorro |
| `!anime <nome>` | Um parametro | Busca informacoes sobre um anime |
| `!traducao <idioma> <texto>` | Dois parametros | Traduz texto do portugues para outro idioma |
| `!conv <valor> <origem> <destino>` | Dois parametros | Converte valores entre moedas |
| `!lembrar <texto>` | Persistencia | Salva um lembrete para o usuario |
| `!lembretes` | Persistencia | Lista os lembretes salvos do usuario |
| `!curiosidade <numero>` | Combina duas APIs | Fato curioso + resumo da Wikipedia |
| `!gemini <pergunta>` | Um parametro | Consulta a IA do Google Gemini |

---

## Exemplos de Uso

### !ping
```
!ping
> Pong! Bot online e funcionando!
```

### !cachorro
```
!cachorro
> [foto de um cachorro]
```

### !anime
```
!anime naruto
> **Naruto**
> Episodios: 220
> Nota: 7.97
> Status: Finished Airing
> Sinopse: Moments prior to Naruto Uzumaki's birth...
```

### !traducao
```
!traducao en Bom dia
> Traducao (pt -> en): Good morning

!traducao es Como vai voce
> Traducao (pt -> es): Como te va
```

Idiomas disponiveis: en (ingles), es (espanhol), fr (frances), de (alemao), it (italiano), ja (japones), ko (coreano), zh (chines), ru (russo)

### !conv
```
!conv 100 USD BRL
> 100 USD = 515.30 BRL

!conv 50 EUR USD
> 50 EUR = 54.20 USD
```

### !lembrar e !lembretes
```
!lembrar Estudar para a prova amanha
> Anotado! Vou me lembrar disso!

!lembretes
> Seus lembretes:
> 1. Estudar para a prova amanha
```

### !curiosidade
```
!curiosidade 42
> Curiosidade aleatoria:
> Sugar was first added to chewing gum in 1869 by a dentist.
>
> Wikipedia sobre 42:
> 42 foi um ano comum do seculo I...
```

### !gemini
```
!gemini qual a capital do brasil?
> A capital do Brasil e Brasilia...

!gemini explique recursao em programacao
> Recursao e uma tecnica onde uma funcao chama a si mesma...
```

---

## Persistencia de Dados

O comando `!lembrar` salva os lembretes de cada usuario no arquivo `lembretes.json`. O arquivo e:

- Lido ao iniciar o bot via `AstroBot.Store`
- Atualizado a cada novo lembrete salvo
- Organizado por ID de usuario do Discord

Exemplo de estrutura do arquivo:
```json
{
  "123456789": ["Estudar para a prova", "Comprar leite"],
  "987654321": ["Reuniao as 10h"]
}
```

O arquivo `lembretes.json` nao e enviado ao repositorio (esta no `.gitignore`).

---

## Arquitetura

```
lib/
├── astro_bot.ex              # Modulo principal
└── astro_bot/
    ├── application.ex        # Ponto de entrada e Supervisor OTP
    ├── consumer.ex           # Handler de eventos do Discord
    ├── commands.ex           # Implementacao dos comandos
    └── store.ex              # Persistencia JSON via GenServer
```

| Modulo | Responsabilidade |
|--------|-----------------|
| `AstroBot.Application` | Inicia e supervisiona os processos com OTP Supervisor |
| `AstroBot.Consumer` | Recebe eventos do Discord e despacha comandos via pattern matching |
| `AstroBot.Commands` | Implementa cada comando com funcoes puras e pipe operator |
| `AstroBot.Store` | Gerencia leitura e escrita do JSON usando GenServer |

---

## APIs Utilizadas

| Comando | API | Documentacao |
|---------|-----|-------------|
| `!cachorro` | Dog CEO API | dog.ceo/dog-api |
| `!anime` | Jikan API | jikan.moe |
| `!traducao` | MyMemory API | mymemory.translated.net |
| `!conv` | ExchangeRate API | open.er-api.com |
| `!curiosidade` | UselessFacts + Wikipedia | uselessfacts.jsph.pl / wikipedia.org |
| `!gemini` | Google Gemini API | aistudio.google.com |
| `!lembrar` | Nenhuma (JSON local) | — |

---

## Conceitos Funcionais

| Conceito | Onde e aplicado |
|----------|----------------|
| **Pattern matching** | Despacho de comandos em `Consumer` e `Commands` via clausulas de funcao |
| **Pipe operator (\|>)** | Encadeamento de transformacoes em todos os comandos |
| **Imutabilidade** | Estado gerenciado pelo GenServer sem variaveis globais |
| **GenServer** | `AstroBot.Store` gerencia estado compartilhado entre sessoes |
| **Supervisor OTP** | `AstroBot.Application` supervisiona os processos do bot |
| **Serializacao JSON** | Persistencia de lembretes via biblioteca Jason |
| **Recursao** | Loop de eventos gerenciado internamente pelo Nostrum |