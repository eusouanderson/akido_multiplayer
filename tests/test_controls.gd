## Testes da Tela de Controles (scenes/controls.tscn + scripts/ui/controls.gd)
extends Object

var runner

func run_all() -> void:
	test_scene_carrega()
	test_script_atribuido()
	test_nos_existem()
	test_option_buttons_tem_itens()
	test_botao_back_conectado()
	test_device_to_idx_teclados()

# ── Carregamento ─────────────────────────────────────────────────
func test_scene_carrega() -> void:
	runner.assert_not_null(load("res://scenes/controls.tscn"),
		"controls.tscn carrega sem erros")

func test_script_atribuido() -> void:
	var s = _instanciar()
	if s == null: return
	runner.assert_true(s.get_script() != null,
		"controls.tscn tem script GDScript atribuído")
	s.free()

# ── Estrutura de nós ─────────────────────────────────────────────
func test_nos_existem() -> void:
	var s = _instanciar()
	if s == null: return

	var nos := [
		"CC/VBox/P1Row/P1DeviceOption",
		"CC/VBox/P2Row/P2DeviceOption",
		"CC/VBox/JoysticksLabel",
		"CC/VBox/TestLabel",
		"CC/VBox/BtnBack",
	]
	for path in nos:
		runner.assert_not_null(s.get_node_or_null(path),
			"Nó existe: %s" % path.get_file())
	s.free()

# ── OptionButtons ─────────────────────────────────────────────────
func test_option_buttons_tem_itens() -> void:
	## Após _ready(), cada OptionButton deve ter ao menos 2 itens
	## (Teclado P1 e Teclado P2), independente de joypads conectados.
	var s = _instanciar_com_ready()
	if s == null: return

	var p1_opt = s.get_node_or_null("CC/VBox/P1Row/P1DeviceOption")
	var p2_opt = s.get_node_or_null("CC/VBox/P2Row/P2DeviceOption")

	if p1_opt:
		runner.assert_true(p1_opt.item_count >= 2,
			"P1DeviceOption tem ao menos 2 itens (teclados)")
	if p2_opt:
		runner.assert_true(p2_opt.item_count >= 2,
			"P2DeviceOption tem ao menos 2 itens (teclados)")
	s.free()

# ── Sinal do botão Voltar ─────────────────────────────────────────
func test_botao_back_conectado() -> void:
	var s = _instanciar_com_ready()
	if s == null: return
	var btn = s.get_node_or_null("CC/VBox/BtnBack")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnBack tem sinal 'pressed' conectado"
	)
	s.free()

# ── Lógica de mapeamento device ↔ índice ──────────────────────────
func test_device_to_idx_teclados() -> void:
	## Verifica que os OptionButtons iniciam selecionados nos dispositivos padrão:
	## P1 → KEYBOARD_P1 (idx 0), P2 → KEYBOARD_P2 (idx 1).
	var s = _instanciar_com_ready()
	if s == null: return

	var p1_opt = s.get_node_or_null("CC/VBox/P1Row/P1DeviceOption")
	var p2_opt = s.get_node_or_null("CC/VBox/P2Row/P2DeviceOption")

	if p1_opt:
		runner.assert_eq(p1_opt.selected, 0,
			"P1DeviceOption: seleção padrão = 0 (Teclado WASD)")
	if p2_opt:
		runner.assert_eq(p2_opt.selected, 1,
			"P2DeviceOption: seleção padrão = 1 (Teclado Setas)")
	s.free()

# ── Helpers ──────────────────────────────────────────────────────
func _instanciar() -> Node:
	var packed = load("res://scenes/controls.tscn")
	if packed == null:
		runner.assert_true(false, "Falha ao carregar controls.tscn")
		return null
	return packed.instantiate()

func _instanciar_com_ready() -> Node:
	var s = _instanciar()
	if s == null: return null
	var root := Node.new()
	root.add_child(s)
	s._ready()
	root.remove_child(s)
	root.free()
	return s
