# CLAUDE.md — Guia do Projeto para o Claude Code

## Motor e versão
- **Godot 4.3** — Forward+ renderer
- **GDScript** — sem C# ou GDNative
- Instalado via Flatpak: `org.godotengine.Godot`

## Comandos rápidos
```bash
./run.sh          # abre o editor Godot
./run.sh --game   # roda o jogo diretamente
./test.sh         # executa os 41 testes de menu
./export.sh linux # exporta para Linux
```

## Arquitetura dos scripts

```
scripts/
  ui/           → menu.gd, settings.gd, lobby.gd
  player/       → player_base.gd (classe base), player1.gd, player2.gd
  world/        → area_2d.gd (hitbox), parallax_background.gd
```

**Padrão de herança do player:**
- `player_base.gd` — toda a lógica de física (gravidade, pulo, ataque, movimento)
- `player1.gd` — estende player_base, override de `_handle_jump` para jump-attack
- `player2.gd` — estende player_base sem modificações adicionais

## Convenções de código GDScript
- Todos os tipos declarados explicitamente: `var speed: float = 800.0`
- Constantes em `UPPER_SNAKE_CASE`, variáveis em `snake_case`
- Comentários de seção com `## ── Título ──` (duas cerquilhas)
- Scripts começam com `## NomeDaClasse — Descrição breve.`

## Testes
- Runner próprio (`tests/test_runner.gd`) sem dependências externas
- Cada suite é um `Object` com método `run_all()` e referência `runner`
- Rodar **sempre** em modo com display (não headless) — assets precisam estar importados

## Input map
| Action         | Bind                        |
|----------------|-----------------------------|
| `ui_left`      | Seta ← / A                  |
| `ui_right`     | Seta → / D                  |
| `ui_up`        | Seta ↑ / W                  |
| `ui_accept`    | Space (pulo)                |
| `ui_attack`    | Mouse botão esquerdo        |
| `ui_mega_attack` | Mouse botão direito       |

## O que NÃO fazer
- **Não mover assets/cenas pelo terminal** sem depois abrir o editor para revalidar UIDs
- **Não commitar** `*.tmp`, `*.uid`, `*.pxo`, `*.psd` (já no .gitignore)
- **Não usar** `player1.gd` nem `player2.gd` como classes base — use `player_base.gd`
