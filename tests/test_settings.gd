## Testes da Tela de Configurações (scenes/settings.tscn + scripts/settings.gd)
extends Object

var runner

func run_all() -> void:
	test_scene_carrega()
	test_nos_existem()
	test_slider_limites()
	test_botao_voltar_existe()
	test_botao_voltar_conectado()

func test_scene_carrega() -> void:
	var packed = load("res://scenes/settings.tscn")
	runner.assert_not_null(packed, "settings.tscn carrega sem erros")

func test_nos_existem() -> void:
	var settings = _instanciar()
	if settings == null: return

	var nos = [
		"CC/VBox/Title",
		"CC/VBox/MasterVolRow/MasterVolSlider",
		"CC/VBox/FullscreenCheck",
		"CC/VBox/BtnBack",
	]
	for path in nos:
		runner.assert_not_null(
			settings.get_node_or_null(path),
			"Nó existe: %s" % path.get_file()
		)

	settings.free()

func test_slider_limites() -> void:
	var settings = _instanciar()
	if settings == null: return

	var slider = settings.get_node_or_null(
		"CC/VBox/MasterVolRow/MasterVolSlider"
	)
	if slider:
		runner.assert_eq(slider.min_value, 0.0, "Slider min_value = 0.0")
		runner.assert_eq(slider.max_value, 1.0, "Slider max_value = 1.0")
		runner.assert_true(slider.value >= 0.0 and slider.value <= 1.0,
			"Slider value está no intervalo [0, 1]")

	settings.free()

func test_botao_voltar_existe() -> void:
	var settings = _instanciar()
	if settings == null: return

	var btn = settings.get_node_or_null("CC/VBox/BtnBack")
	runner.assert_not_null(btn, "Botão Voltar existe")
	if btn:
		runner.assert_true(btn.text.length() > 0, "Botão Voltar tem texto")

	settings.free()

func test_botao_voltar_conectado() -> void:
	var settings = _instanciar_com_sinais()
	if settings == null: return

	var btn = settings.get_node_or_null("CC/VBox/BtnBack")
	runner.assert_true(
		btn != null and btn.pressed.get_connections().size() > 0,
		"BtnBack tem sinal 'pressed' conectado"
	)
	settings.free()

# ── Helpers ─────────────────────────────────────────────────────
func _instanciar() -> Node:
	var packed = load("res://scenes/settings.tscn")
	if packed == null:
		runner.assert_true(false, "Falha ao carregar settings.tscn")
		return null
	return packed.instantiate()

func _instanciar_com_sinais() -> Node:
	var s = _instanciar()
	if s == null: return null
	var root = Node.new()
	root.add_child(s)
	s._ready()
	root.remove_child(s)
	root.free()
	return s
