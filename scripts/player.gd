extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_attacking = false  # Variável para controlar o estado de ataque
var is_mega_attacking = false # Variável para controlar o estado do mega attack

func _ready() -> void:
	# Conectar o sinal "animation_finished" ao método "_on_attack_finished"
	animated_sprite.connect("animation_finished", Callable(self, "_on_attack_finished"))

func _physics_process(delta: float) -> void:
	# Adiciona gravidade se não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Se o botão de ataque (mouse) estiver pressionado
	if Input.is_action_pressed("ui_attack"):
		if not is_attacking and not is_mega_attacking:
			attack()  # Inicia o ataque
		else:
			# Enquanto o botão estiver pressionado, toca a animação de ataque parcial
			if is_attacking:
				animated_sprite.play("attack_partial")  # Animação de ataque parcial

	# Handle Mega attack
	if Input.is_action_just_pressed("ui_mega_attack") and not is_mega_attacking:
		mega_attack()

	# Se estiver atacando, pare toda a movimentação e mostre apenas a animação de ataque
	if is_attacking or is_mega_attacking:
		return  # Impede que outras animações ou movimentação ocorram enquanto ataca

	# Obtém a direção de entrada para movimento esquerdo e direito
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Atualiza a velocidade horizontal com base na entrada
	if direction != 0:
		velocity.x = direction * SPEED
		# Toca a animação de corrida se não estiver atacando
		animated_sprite.play("run")
		# Inverte o sprite com base na direção
		animated_sprite.flip_h = direction < 0
	else:
		# Desacelera se nenhuma direção for pressionada
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# Toca a animação de inatividade se não estiver se movendo e não atacando
		if is_on_floor():
			animated_sprite.play("idle")

	# Move o personagem
	move_and_slide()

func attack():
	# Define que o personagem está atacando e toca a animação de ataque
	is_attacking = true
	animated_sprite.play("attack")  # Inicia a animação de ataque

func mega_attack():
	# Define que o personagem está atacando e toca a animação de mega ataque
	is_mega_attacking = true
	animated_sprite.play("mega_attack")

func _on_attack_finished():
	# Quando a animação de ataque terminar, volta para o estado normal
	is_attacking = false
	is_mega_attacking = false
