## Player1 — Jogador 1.
##
## Usa player_id = 1 → lê ações p1_* (WASD + mouse por padrão).
## Override de _handle_jump: pulo-ataque quando estiver no meio de um ataque.
extends "res://scripts/player/player_base.gd"

func _ready() -> void:
	player_id = 1
	super._ready()

# ── Pulo com ataque ──────────────────────────────────────────────────────────

func _handle_jump() -> void:
	if _just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump_attack" if (is_attacking or is_mega_attacking) else "jump")
