## Testes do Lobby Online (scenes/lobby.tscn + scripts/lobby.gd)
extends Object

var runner

func run_all() -> void:
	test_scene_carrega()
	test_nos_existem()
	test_input_endereco_tem_placeholder()
	test_status_label_vazio_no_inicio()
	test_botao_host_conectado()
	test_botao_join_conectado()
	test_botao_voltar_conectado()
	test_constante_porta()

func test_scene_carrega() -> void:
	var packed = load("res://scenes/lobby.tscn")
	runner.assert_not_null(packed, "lobby.tscn carrega sem erros")

func test_nos_existem() -> void:
	var lobby = _instanciar()
	if lobby == null: return

	var nos = [
		"CenterContainer/VBoxContainer/BtnHost",
		"CenterContainer/VBoxContainer/JoinContainer/AddressInput",
		"CenterContainer/VBoxContainer/JoinContainer/BtnJoin",
		"CenterContainer/VBoxContainer/StatusLabel",
		"CenterContainer/VBoxContainer/BtnBack",
	]
	for path in nos:
		runner.assert_not_null(
			lobby.get_node_or_null(path),
			"Nó existe: %s" % path.get_file()
		)

	lobby.free()

func test_input_endereco_tem_placeholder() -> void:
	var lobby = _instanciar()
	if lobby == null: return

	var input = lobby.get_node_or_null(
		"CenterContainer/VBoxContainer/JoinContainer/AddressInput"
	)
	if input:
		runner.assert_true(
			input.placeholder_text.length() > 0,
			"Campo de endereço tem placeholder_text"
		)
		runner.assert_true(
			input.text.length() > 0,
			"Campo de endereço tem valor padrão (ex: 127.0.0.1)"
		)

	lobby.free()

func test_status_label_vazio_no_inicio() -> void:
	var lobby = _instanciar()
	if lobby == null: return

	var label = lobby.get_node_or_null("CenterContainer/VBoxContainer/StatusLabel")
	if label:
		runner.assert_eq(label.text, "", "StatusLabel começa vazio")

	lobby.free()

func test_constante_porta() -> void:
	var script = load("res://scripts/ui/lobby.gd")
	runner.assert_not_null(script, "lobby.gd carrega sem erros")
	# Verifica que a porta está dentro de um range válido (1024–65535)
	var lobby = _instanciar()
	if lobby == null: return
	var port = lobby.get("PORT")
	runner.assert_true(
		port != null and port >= 1024 and port <= 65535,
		"Constante PORT é um valor válido (%s)" % str(port)
	)
	lobby.free()

func test_botao_host_conectado() -> void:
	var lobby = _instanciar_com_sinais()
	if lobby == null: return
	var btn = lobby.get_node_or_null("CenterContainer/VBoxContainer/BtnHost")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnHost tem sinal 'pressed' conectado"
	)
	lobby.free()

func test_botao_join_conectado() -> void:
	var lobby = _instanciar_com_sinais()
	if lobby == null: return
	var btn = lobby.get_node_or_null("CenterContainer/VBoxContainer/JoinContainer/BtnJoin")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnJoin tem sinal 'pressed' conectado"
	)
	lobby.free()

func test_botao_voltar_conectado() -> void:
	var lobby = _instanciar_com_sinais()
	if lobby == null: return
	var btn = lobby.get_node_or_null("CenterContainer/VBoxContainer/BtnBack")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnBack tem sinal 'pressed' conectado"
	)
	lobby.free()

# ── Helpers ─────────────────────────────────────────────────────
func _instanciar() -> Node:
	var packed = load("res://scenes/lobby.tscn")
	if packed == null:
		runner.assert_true(false, "Falha ao carregar lobby.tscn")
		return null
	return packed.instantiate()

func _instanciar_com_sinais() -> Node:
	var lobby = _instanciar()
	if lobby == null: return null
	var root = Node.new()
	root.add_child(lobby)
	lobby._ready()
	root.remove_child(lobby)
	root.free()
	return lobby
