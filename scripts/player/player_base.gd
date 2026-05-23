## PlayerBase — Lógica compartilhada entre todos os jogadores.
##
## Gerencia: gravidade, pulo, ataque, mega-ataque e animações de movimento.
## Estenda esta classe em player1.gd e player2.gd para comportamentos específicos.
class_name PlayerBase
extends CharacterBody2D

# ── Constantes ──────────────────────────────────────────────────────────────
const SPEED: float        = 800.0   ## Velocidade horizontal de movimento
const JUMP_VELOCITY: float = -400.0  ## Velocidade vertical inicial do pulo

# ── Referências de nó ────────────────────────────────────────────────────────
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# ── Estado ───────────────────────────────────────────────────────────────────
var is_attacking: bool      = false  ## Verdadeiro durante a animação de ataque normal
var is_mega_attacking: bool = false  ## Verdadeiro durante a animação de mega-ataque

# ── Ciclo de vida ────────────────────────────────────────────────────────────

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_attack()
	_handle_movement()
	move_and_slide()

# ── Física ───────────────────────────────────────────────────────────────────

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# ── Entrada: pulo ────────────────────────────────────────────────────────────

func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")

# ── Entrada: ataques ─────────────────────────────────────────────────────────

func _handle_attack() -> void:
	if Input.is_action_just_pressed("ui_attack"):
		if not is_attacking and not is_mega_attacking:
			_start_attack()
			return
	if Input.is_action_just_pressed("ui_mega_attack"):
		if not is_mega_attacking and not is_attacking:
			_start_mega_attack()

func _start_attack() -> void:
	is_attacking = true
	animated_sprite.play("attack")

func _start_mega_attack() -> void:
	is_mega_attacking = true
	animated_sprite.play("mega_attack")

# ── Entrada: movimento ───────────────────────────────────────────────────────

func _handle_movement() -> void:
	if is_attacking or is_mega_attacking:
		# Durante ataques, o personagem desacelera gradualmente
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		return

	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0.0
		if is_on_floor():
			animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		if is_on_floor():
			animated_sprite.play("idle")

# ── Callbacks de animação ────────────────────────────────────────────────────

func _on_animation_finished() -> void:
	## Chamado quando qualquer animação não-loop termina.
	## Redefine os flags de ataque para retomar o controle normal.
	is_attacking = false
	is_mega_attacking = false
