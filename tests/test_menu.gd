## Testes do Menu Principal (scenes/menu.tscn + scripts/menu.gd)
extends Object

var runner  # referência ao TestRunner para chamar assert_*

func run_all() -> void:
	test_scene_carrega()
	test_botoes_existem()
	test_titulo_existe()
	test_script_correto()
	test_botao_play_local_conectado()
	test_botao_play_online_conectado()
	test_botao_settings_conectado()
	test_botao_quit_conectado()
	test_textos_dos_botoes()

# ── Carregamento ────────────────────────────────────────────────
func test_scene_carrega() -> void:
	var packed = load("res://scenes/menu.tscn")
	runner.assert_not_null(packed, "menu.tscn carrega sem erros")

func test_script_correto() -> void:
	var menu = _instanciar()
	if menu == null: return
	runner.assert_true(
		menu.get_script() != null,
		"menu.tscn tem script GDScript atribuído"
	)
	menu.free()

# ── Estrutura de nós ────────────────────────────────────────────
func test_botoes_existem() -> void:
	var menu = _instanciar()
	if menu == null: return

	var botoes = [
		"CenterContainer/VBoxContainer/BtnPlayLocal",
		"CenterContainer/VBoxContainer/BtnPlayOnline",
		"CenterContainer/VBoxContainer/BtnSettings",
		"CenterContainer/VBoxContainer/BtnQuit",
	]
	for path in botoes:
		var node = menu.get_node_or_null(path)
		runner.assert_not_null(node, "Nó existe: %s" % path)

	menu.free()

func test_titulo_existe() -> void:
	var menu = _instanciar()
	if menu == null: return
	var title = menu.get_node_or_null("CenterContainer/VBoxContainer/Title")
	runner.assert_not_null(title, "Label de título existe")
	if title:
		runner.assert_true(title.text.length() > 0, "Título não está vazio")
	menu.free()

# ── Textos dos botões ───────────────────────────────────────────
func test_textos_dos_botoes() -> void:
	var menu = _instanciar()
	if menu == null: return

	var esperados = {
		"CenterContainer/VBoxContainer/BtnPlayLocal":   "Jogar Local (2 Jogadores)",
		"CenterContainer/VBoxContainer/BtnPlayOnline":  "Jogar Online",
		"CenterContainer/VBoxContainer/BtnSettings":    "Configurações",
		"CenterContainer/VBoxContainer/BtnQuit":        "Sair",
	}
	for path in esperados:
		var node = menu.get_node_or_null(path)
		if node:
			runner.assert_eq(node.text, esperados[path],
				"Texto correto em '%s'" % path.get_file())

	menu.free()

# ── Conexão dos sinais ──────────────────────────────────────────
func test_botao_play_local_conectado() -> void:
	var menu = _instanciar_com_sinais()
	if menu == null: return
	var btn = menu.get_node_or_null("CenterContainer/VBoxContainer/BtnPlayLocal")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnPlayLocal tem sinal 'pressed' conectado"
	)
	menu.free()

func test_botao_play_online_conectado() -> void:
	var menu = _instanciar_com_sinais()
	if menu == null: return
	var btn = menu.get_node_or_null("CenterContainer/VBoxContainer/BtnPlayOnline")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnPlayOnline tem sinal 'pressed' conectado"
	)
	menu.free()

func test_botao_settings_conectado() -> void:
	var menu = _instanciar_com_sinais()
	if menu == null: return
	var btn = menu.get_node_or_null("CenterContainer/VBoxContainer/BtnSettings")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnSettings tem sinal 'pressed' conectado"
	)
	menu.free()

func test_botao_quit_conectado() -> void:
	var menu = _instanciar_com_sinais()
	if menu == null: return
	var btn = menu.get_node_or_null("CenterContainer/VBoxContainer/BtnQuit")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnQuit tem sinal 'pressed' conectado"
	)
	menu.free()

# ── Helpers ─────────────────────────────────────────────────────
func _instanciar() -> Node:
	var packed = load("res://scenes/menu.tscn")
	if packed == null:
		runner.assert_true(false, "Falha ao carregar menu.tscn")
		return null
	return packed.instantiate()

func _instanciar_com_sinais() -> Node:
	## Instancia e chama _ready() para registrar as conexões de sinal
	var menu = _instanciar()
	if menu == null: return null
	# Adiciona temporariamente ao root para _ready() ser chamado
	var root = Node.new()
	root.add_child(menu)
	menu._ready()
	root.remove_child(menu)
	root.free()
	return menu
