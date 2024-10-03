extends ParallaxBackground

# Velocidade do fundo (ajuste conforme necessário)
var speed: Vector2 = Vector2(50, 0)  # Velocidade horizontal
var player: CharacterBody2D

# Tamanho do layer (largura) que você deseja fazer o loop
const LAYER_WIDTH: float = 928

func _ready() -> void:
	# Obtém a referência ao jogador (ajuste o nome do nó conforme necessário)
	player = get_node("../Player")  # Ajuste o caminho conforme a estrutura da sua cena

func _process(delta: float) -> void:
	# Atualiza o offset de rolagem baseado no tempo
	scroll_offset += speed * delta

	# Se o scroll_offset ultrapassar a largura do layer, reinicie
	if scroll_offset.x >= LAYER_WIDTH:
		scroll_offset.x -= LAYER_WIDTH  # Move o offset para trás pela largura do layer

	# Mover o fundo em resposta ao movimento do jogador
	if player:
		# Calcule a posição do jogador e ajuste o offset
		var player_pos = player.position.x
		scroll_offset.x = player_pos * 0.5  # Ajuste o fator conforme desejado para o efeito de parallax
