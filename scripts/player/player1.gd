## Player1 — Jogador 1 (teclado WASD + mouse).
##
## Estende PlayerBase adicionando comportamento de pulo com ataque:
## se o jogador pular enquanto estiver atacando, reproduz "jump_attack".
extends "res://scripts/player/player_base.gd"

# ── Pulo com ataque ──────────────────────────────────────────────────────────

func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if is_attacking or is_mega_attacking:
			animated_sprite.play("jump_attack")
		else:
			animated_sprite.play("jump")
