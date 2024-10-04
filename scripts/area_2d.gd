extends Area2D

# O que irá conter a referência ao AnimationPlayer
var player_animation_player: AnimationPlayer

func _ready():
	# Certifique-se de que a área está monitorando
	monitoring = true
	# Conectar o sinal body_entered
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Verifique se o corpo que entrou é um jogador
	if body.is_in_group("players"):  # Verifique se o corpo está no grupo "players"
		print("Um corpo entrou na área: ", body)  # Exibe o corpo que entrou
		# Inicie a animação "dead" no AnimationPlayer do jogador
		if body.has_method("play_dead_animation"):  # Verifica se o jogador tem a função
			body.play_dead_animation()  # Chame a função que inicia a animação
