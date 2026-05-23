# Akido Multiplayer

Jogo de luta 2D multiplayer desenvolvido com **Godot 4.3** (Forward+).  
Suporta partidas locais (2 jogadores no mesmo teclado) e online via ENet.

---

## 🚀 Como rodar

```bash
# Abrir o editor Godot
./run.sh

# Rodar o jogo diretamente (sem abrir o editor)
./run.sh --game
```

> **Requisito:** Godot 4.x instalado via Flatpak (`org.godotengine.Godot`)

---

## 🧪 Testes

```bash
# Rodar todos os testes
./test.sh

# Modo watch (reexecuta a cada 3 s)
./test.sh --watch
```

Os testes cobrem os três scripts de menu (menu, configurações e lobby online).  
**41 casos** verificam estrutura de nós, textos, conexões de sinal e limites de valores.

---

## 📦 Exportar

```bash
./export.sh linux    # → builds/linux/AkidoMultiplayer.x86_64
./export.sh windows  # → builds/windows/AkidoMultiplayer.exe
```

> Configure um preset de exportação no Godot Editor antes de exportar.

---

## 🗂️ Estrutura do projeto

```
akido_multiplayer/
├── assets/
│   ├── characters/          # Spritesheets dos personagens
│   └── maps/                # Camadas de parallax do mapa
├── characters/              # Sprites do NightBorne (PNG)
├── scenes/
│   ├── menu.tscn            # Menu principal
│   ├── settings.tscn        # Tela de configurações
│   ├── lobby.tscn           # Lobby online
│   └── game.tscn            # Cena principal do jogo
├── scripts/
│   ├── ui/                  # Menu, settings, lobby
│   │   ├── menu.gd
│   │   ├── settings.gd
│   │   └── lobby.gd
│   ├── player/              # Lógica dos jogadores
│   │   ├── player_base.gd   # Classe base (movimento, ataques)
│   │   ├── player1.gd       # Jogador 1 (jump-attack override)
│   │   └── player2.gd       # Jogador 2
│   └── world/               # Elementos do mundo
│       ├── area_2d.gd       # Detecção de hit
│       └── parallax_background.gd
├── tests/
│   ├── test_runner.gd       # Runner leve (sem dependências externas)
│   ├── test_menu.gd
│   ├── test_settings.gd
│   └── test_lobby.gd
├── source/                  # Arquivos fonte (Pixelorama) — não usados pelo Godot
├── run.sh                   # Abre o editor / roda o jogo
├── test.sh                  # Executa os testes
└── export.sh                # Exporta para Linux / Windows
```

---

## 🎮 Controles

| Ação           | Tecla / Botão       |
|----------------|---------------------|
| Mover          | A / D (ou ←/→)      |
| Pular          | Space / W / ↑       |
| Ataque         | Botão esquerdo do mouse |
| Mega ataque    | Botão direito do mouse  |

---

## 🌐 Multiplayer online

1. **Host:** clique em *Jogar Online → Hospedar Partida*  
2. **Cliente:** informe o IP do host e clique em *Entrar*  
3. O jogo usa **ENet** na porta **7777** (TCP/UDP)

---

## 👥 Equipe

Desenvolvido por **Bob** — Faculdade Impacta (anderson.rsilva@aluno.impacta.edu.br)
