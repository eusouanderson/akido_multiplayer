extends ParallaxBackground

# Velocidade do fundo (ajuste conforme necessário)
var speed: Vector2 = Vector2(50, 0)  # Velocidade horizontal para controle manual, se necessário
var player: CharacterBody2D

# Tamanho do layer (largura) que você deseja fazer o loop
const LAYER_WIDTH: float = 928

func _ready() -> void:
	# Obtém a referência ao jogador (ajuste o nome do nó conforme necessário)
	player = get_node("../Player")  # Ajuste o caminho conforme a estrutura da sua cena

func _process(delta: float) -> void:
	# Mover o fundo em resposta ao movimento do jogador
	if player:
		# Calcule a posição do jogador e ajuste o offset de rolagem para o efeito de parallax
		var player_pos = player.position.x

		# Ajuste o fator para o efeito de parallax
		scroll_offset.x = -player_pos * 0.5  # Multiplica por um fator para a velocidade de parallax desejada

		# Loop contínuo: se o scroll_offset ultrapassar os limites, reinicie suavemente
		scroll_offset.x = fmod(scroll_offset.x, LAYER_WIDTH)  # Usa o fmod para garantir o loop suave
