## Player2 — Jogador 2.
##
## Usa player_id = 2 → lê ações p2_* (Setas + J/K por padrão).
## Em modo SOLO se desativa automaticamente.
extends "res://scripts/player/player_base.gd"

func _ready() -> void:
	player_id = 2
	# Em modo Solo o jogador 2 não existe
	if GameState.game_mode == GameState.GameMode.SOLO:
		process_mode = PROCESS_MODE_DISABLED
		visible      = false
		return
	super._ready()
