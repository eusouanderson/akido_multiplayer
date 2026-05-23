extends Control

const PORT = 7777
const MAX_PLAYERS = 2

var peer: ENetMultiplayerPeer

func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnHost.pressed.connect(_on_btn_host_pressed)
	$CenterContainer/VBoxContainer/JoinContainer/BtnJoin.pressed.connect(_on_btn_join_pressed)
	$CenterContainer/VBoxContainer/BtnBack.pressed.connect(_on_btn_back_pressed)

	# multiplayer só está disponível quando o nó está na SceneTree
	if is_inside_tree() and multiplayer:
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)

func _on_btn_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		_set_status("Erro ao criar servidor: " + str(err))
		return
	multiplayer.multiplayer_peer = peer
	_set_status("Servidor iniciado! Aguardando jogadores na porta %d..." % PORT)
	$CenterContainer/VBoxContainer/BtnHost.disabled = true

func _on_btn_join_pressed() -> void:
	var address = $CenterContainer/VBoxContainer/JoinContainer/AddressInput.text
	if address.is_empty():
		address = "127.0.0.1"
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, PORT)
	if err != OK:
		_set_status("Erro ao conectar: " + str(err))
		return
	multiplayer.multiplayer_peer = peer
	_set_status("Conectando ao servidor %s:%d..." % [address, PORT])
	$CenterContainer/VBoxContainer/JoinContainer/BtnJoin.disabled = true

func _on_connected_to_server() -> void:
	_set_status("Conectado! Entrando no jogo...")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_connection_failed() -> void:
	_set_status("Falha na conexão! Verifique o endereço e tente novamente.")
	$CenterContainer/VBoxContainer/JoinContainer/BtnJoin.disabled = false

func _on_peer_connected(id: int) -> void:
	_set_status("Jogador %d conectou! Iniciando jogo..." % id)
	# Apenas o host (id 1) inicia a cena
	if multiplayer.is_server():
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_peer_disconnected(id: int) -> void:
	_set_status("Jogador %d desconectou." % id)

func _on_btn_back_pressed() -> void:
	if peer:
		multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _set_status(msg: String) -> void:
	$CenterContainer/VBoxContainer/StatusLabel.text = msg
