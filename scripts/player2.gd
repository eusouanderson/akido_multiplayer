extends CharacterBody2D

const SPEED = 800.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_attacking = false  # Variável para controlar o estado de ataque
var is_mega_attacking = false  # Variável para controlar o estado de mega ataque

func _ready() -> void:
	# Conectar o sinal "animation_finished" ao método "_on_attack_finished"
	animated_sprite.connect("animation_finished", Callable(self, "_on_attack_finished"))

func _physics_process(delta: float) -> void:
	# Adiciona gravidade se não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump (pulo)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")  # Toca a animação de salto

	# Se o botão de ataque (mouse) estiver pressionado
	if Input.is_action_just_pressed("ui_attack"):
		if not is_attacking and not is_mega_attacking:
			attack()  # Inicia o ataque

	# Handle Mega attack
	if Input.is_action_just_pressed("ui_mega_attack"):
		if not is_mega_attacking and not is_attacking:
			mega_attack()  # Inicia o mega ataque

	# Atualiza a velocidade horizontal com base na entrada do jogador
	var direction := Input.get_axis("ui_left", "ui_right")

	# Verifica se está atacando. Se estiver, o jogador ainda pode se mover, mas a animação de ataque será priorizada.
	if not is_attacking and not is_mega_attacking:
		if direction != 0:
			velocity.x = direction * SPEED
			# Toca a animação de corrida se estiver no chão e se movendo
			if is_on_floor():
				animated_sprite.play("run")
			# Inverte o sprite com base na direção
			animated_sprite.flip_h = direction < 0
		else:
			# Desacelera se nenhuma direção for pressionada
			velocity.x = move_toward(velocity.x, 0, SPEED)
			# Toca a animação de inatividade se não estiver se movendo
			if is_on_floor():
				animated_sprite.play("idle")
	else:
		# Durante o mega ataque ou ataque normal, desacelera gradualmente o personagem
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Move o personagem
	move_and_slide()

func attack():
	# Define que o personagem está atacando e toca a animação de ataque
	is_attacking = true
	animated_sprite.play("attack")  # Inicia a animação de ataque

func mega_attack():
	# Define que o personagem está mega atacando e toca a animação de mega ataque
	is_mega_attacking = true
	animated_sprite.play("mega_attack")

func _on_attack_finished():
	# Quando a animação de ataque terminar, volta para o estado normal
	is_attacking = false
	is_mega_attacking = false
