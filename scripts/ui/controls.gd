## Controls — Tela de configuração de dispositivos de input.
##
## Permite ao jogador escolher o dispositivo (teclado P1, teclado P2 ou joypad)
## para cada jogador. Detecta joypads conectados em tempo real.
extends Control

# ── Referências de nó ────────────────────────────────────────────────────────
@onready var p1_option:     OptionButton = $CC/VBox/P1Row/P1DeviceOption
@onready var p2_option:     OptionButton = $CC/VBox/P2Row/P2DeviceOption
@onready var joy_label:     Label        = $CC/VBox/JoysticksLabel
@onready var test_label:    Label        = $CC/VBox/TestLabel
@onready var btn_back:      Button       = $CC/VBox/BtnBack

# ── Ciclo de vida ────────────────────────────────────────────────────────────

func _ready() -> void:
	_populate_options()
	_refresh_joypad_info()

	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	p1_option.item_selected.connect(_on_p1_selected)
	p2_option.item_selected.connect(_on_p2_selected)
	btn_back.pressed.connect(_on_back_pressed)

func _input(event: InputEvent) -> void:
	# Detecta qualquer botão de joypad e exibe feedback de teste
	if event is InputEventJoypadButton and event.pressed:
		var name := Input.get_joy_name(event.device)
		test_label.text = "✅  Controle %d detectado: %s" % [event.device + 1, name]

# ── População dos OptionButtons ──────────────────────────────────────────────

func _populate_options() -> void:
	for opt in [p1_option, p2_option]:
		opt.clear()
		# ID 0 → KEYBOARD_P1, ID 1 → KEYBOARD_P2, ID 2+ → joypad (index = id - 2)
		opt.add_item("⌨  Teclado WASD + Mouse  (P1 padrão)", 0)
		opt.add_item("⌨  Teclado Setas + J/K   (P2 padrão)", 1)
		for joy_id in Input.get_connected_joypads():
			var joy_name := Input.get_joy_name(joy_id)
			opt.add_item("🎮  %s  (Controle %d)" % [joy_name, joy_id + 1], joy_id + 2)

	# Seleciona a opção atual
	p1_option.selected = _device_to_idx(GameState.player1_device)
	p2_option.selected = _device_to_idx(GameState.player2_device)

func _refresh_joypad_info() -> void:
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		joy_label.text = "Nenhum controle externo detectado."
	else:
		var lines := PackedStringArray()
		for joy_id in joypads:
			lines.append("  • Controle %d: %s" % [joy_id + 1, Input.get_joy_name(joy_id)])
		joy_label.text = "🎮  Controles conectados:\n" + "\n".join(lines)

# ── Conversão device ↔ índice do OptionButton ─────────────────────────────────

func _device_to_idx(device: int) -> int:
	match device:
		GameState.KEYBOARD_P1: return 0
		GameState.KEYBOARD_P2: return 1
		_: return device + 2   # joypad 0 → idx 2, joypad 1 → idx 3 …

func _idx_to_device(opt: OptionButton, idx: int) -> int:
	var item_id := opt.get_item_id(idx)
	match item_id:
		0: return GameState.KEYBOARD_P1
		1: return GameState.KEYBOARD_P2
		_: return item_id - 2  # joypad

# ── Callbacks ────────────────────────────────────────────────────────────────

func _on_p1_selected(idx: int) -> void:
	GameState.set_player_device(1, _idx_to_device(p1_option, idx))
	test_label.text = ""

func _on_p2_selected(idx: int) -> void:
	GameState.set_player_device(2, _idx_to_device(p2_option, idx))
	test_label.text = ""

func _on_joy_connection_changed(_id: int, _connected: bool) -> void:
	_populate_options()
	_refresh_joypad_info()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
