## PlayerBase — Lógica compartilhada entre todos os jogadores.
##
## Gerencia: gravidade, pulo, ataque, mega-ataque e animações.
## O input é lido das ações "p{player_id}_*" registradas pelo GameState.
## Estenda esta classe em player1.gd e player2.gd.
class_name PlayerBase
extends CharacterBody2D

# ── Constantes ───────────────────────────────────────────────────────────────
const SPEED: float         = 800.0   ## Velocidade horizontal máxima
const JUMP_VELOCITY: float = -400.0  ## Impulso vertical do pulo

# ── Configuração ─────────────────────────────────────────────────────────────

## ID do jogador (1 ou 2). Define qual prefixo de ação é lido (p1_* ou p2_*).
## Subclasses devem sobrescrever este valor em _ready() antes de chamar super.
@export var player_id: int = 1

# ── Referências de nó ────────────────────────────────────────────────────────
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# ── Estado ───────────────────────────────────────────────────────────────────
var is_attacking: bool      = false
var is_mega_attacking: bool = false

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

# ── Helpers de input ─────────────────────────────────────────────────────────

## Retorna o nome completo da ação para este jogador.
## Exemplo: _action("jump") → "p1_jump" para player_id = 1.
func _action(suffix: String) -> String:
	return "p%d_%s" % [player_id, suffix]

## Verifica se uma ação deste jogador foi pressionada neste frame.
func _just_pressed(suffix: String) -> bool:
	return Input.is_action_just_pressed(_action(suffix))

## Retorna o eixo de movimento (negativo=esq, positivo=dir).
func _axis(neg: String, pos: String) -> float:
	return Input.get_axis(_action(neg), _action(pos))

# ── Entrada: pulo ────────────────────────────────────────────────────────────

func _handle_jump() -> void:
	if _just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")

# ── Entrada: ataques ─────────────────────────────────────────────────────────

func _handle_attack() -> void:
	if _just_pressed("attack") and not is_attacking and not is_mega_attacking:
		_start_attack()
		return
	if _just_pressed("mega_attack") and not is_mega_attacking and not is_attacking:
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
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		return

	var direction: float = _axis("left", "right")
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
	is_attacking      = false
	is_mega_attacking = false
