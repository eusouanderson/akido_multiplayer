## Testes do Menu de Pausa (scenes/pause_menu.tscn + scripts/ui/pause_menu.gd)
extends Object

var runner

func run_all() -> void:
	test_scene_carrega()
	test_script_atribuido()
	test_nos_existem()
	test_textos_dos_botoes()
	test_botoes_conectados()
	test_inicia_oculto()

# ── Carregamento ─────────────────────────────────────────────────
func test_scene_carrega() -> void:
	runner.assert_not_null(load("res://scenes/pause_menu.tscn"),
		"pause_menu.tscn carrega sem erros")

func test_script_atribuido() -> void:
	var menu = _instanciar()
	if menu == null: return
	runner.assert_true(menu.get_script() != null,
		"pause_menu.tscn tem script GDScript atribuído")
	menu.free()

# ── Estrutura de nós ─────────────────────────────────────────────
func test_nos_existem() -> void:
	var menu = _instanciar()
	if menu == null: return

	var nos := [
		"BG/Center/Panel/Margin/VBox/BtnContinuar",
		"BG/Center/Panel/Margin/VBox/BtnMenuPrincipal",
		"BG/Center/Panel/Margin/VBox/BtnSair",
		"BG/Center/Panel/Margin/VBox/TitleLabel",
	]
	for path in nos:
		runner.assert_not_null(menu.get_node_or_null(path),
			"Nó existe: %s" % path.get_file())
	menu.free()

func test_textos_dos_botoes() -> void:
	var menu = _instanciar()
	if menu == null: return

	var esperados := {
		"BG/Center/Panel/Margin/VBox/BtnContinuar":    "Continuar",
		"BG/Center/Panel/Margin/VBox/BtnMenuPrincipal":"Menu Principal",
		"BG/Center/Panel/Margin/VBox/BtnSair":         "Sair",
	}
	for path in esperados:
		var node = menu.get_node_or_null(path)
		if node:
			runner.assert_eq(node.text, esperados[path],
				"Texto correto em '%s'" % path.get_file())
	menu.free()

# ── Sinais e visibilidade ─────────────────────────────────────────
func test_botoes_conectados() -> void:
	var menu = _instanciar_com_ready()
	if menu == null: return

	var btns := [
		"BG/Center/Panel/Margin/VBox/BtnContinuar",
		"BG/Center/Panel/Margin/VBox/BtnMenuPrincipal",
		"BG/Center/Panel/Margin/VBox/BtnSair",
	]
	for path in btns:
		var btn = menu.get_node_or_null(path)
		runner.assert_true(
			btn != null and btn.pressed.get_connections().size() > 0,
			"'%s' tem sinal pressed conectado" % path.get_file()
		)
	menu.free()

func test_inicia_oculto() -> void:
	## O menu de pausa deve começar escondido (hide() no _ready).
	var menu = _instanciar_com_ready()
	if menu == null: return
	runner.assert_false(menu.visible, "PauseMenu inicia oculto (visible = false)")
	menu.free()

# ── Helpers ──────────────────────────────────────────────────────
func _instanciar() -> Node:
	var packed = load("res://scenes/pause_menu.tscn")
	if packed == null:
		runner.assert_true(false, "Falha ao carregar pause_menu.tscn")
		return null
	return packed.instantiate()

func _instanciar_com_ready() -> Node:
	var menu = _instanciar()
	if menu == null: return null
	var root := Node.new()
	root.add_child(menu)
	menu._ready()
	root.remove_child(menu)
	root.free()
	return menu
