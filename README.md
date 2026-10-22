# Turbo Chat

Salas de conversa instantâneas. Sem cadastro, sem banco de dados e sem histórico: as mensagens só **transitam** entre quem está na sala e nunca são gravadas.

Ruby 4.0.8 · Rails 8.1 (só Action Pack, Action View e Action Cable) · Hotwire (Turbo + Stimulus) · importmap · CSS puro · instalável como PWA.

## Rodando

Requisitos: Ruby 4.0.8 (`mise install`) e [Task](https://taskfile.dev).

```sh
task dev     # http://localhost:3000 (também acessível pela rede local, para testar no celular)
task test    # testes
task check   # testes + rubocop + brakeman + bundler-audit
```

Não há build de assets nem Node: o CSS e o JS são servidos direto pelo Propshaft e o importmap.

## Como funciona

| Coisa | Onde vive |
|---|---|
| Sala | Só um token aleatório de 128 bits na URL (`/r/:token`). Existe enquanto alguém está nela. |
| Usuário | Nome + id aleatório no cookie de sessão (criptografado). |
| Mensagem | `POST` → validada → transmitida via Turbo Stream para a sala → esquecida. |
| Quem está online | Memória do processo (`Presence`), atualizada pelo `RoomChannel` ao entrar/sair. |

## Segurança

- Identidade do WebSocket vem do cookie de sessão, nunca de parâmetros do cliente.
- Streams assinados pelo Turbo; tokens de sala com formato validado na rota.
- CSP rígida com nonce (`default-src 'none'`), HSTS, CSRF.
- `rate_limit` em criar sala, definir nome e enviar mensagem.
- Conteúdo e nome filtrados dos logs (`[FILTERED]`); transmissões só aparecem em nível `debug`.

## Limite conhecido

O adapter do Action Cable é `async` (em memória). Isso exige **um único processo Puma**. Para escalar horizontalmente, troque para `adapter: redis` em `config/cable.yml` e mova `Presence` para conjuntos no Redis (que só repassa, não armazena).

## Deploy

Kamal: preencha `config/deploy.yml` e exporte `SECRET_KEY_BASE` (gere com `bin/rails secret`) e `KAMAL_REGISTRY_PASSWORD`.
