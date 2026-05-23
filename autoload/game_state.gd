## GameState — Singleton global de estado da partida.
##
## Responsável por:
##   • Modo de jogo (Solo / Local 2P / Online)
##   • Dispositivo de input de cada jogador (teclado P1, teclado P2 ou joypad)
##   • Registro dinâmico das ações p1_* e p2_* no InputMap do Godot
extends Node

# ── Enums ────────────────────────────────────────────────────────────────────

enum GameMode {
	SOLO      = 1,  ## Um único jogador
	LOCAL_DUO = 2,  ## Dois jogadores na mesma máquina
	ONLINE    = 3,  ## Partida online via ENet
}

# ── Constantes de dispositivo ────────────────────────────────────────────────

## Teclado padrão do Jogador 1: WASD + botões do mouse.
const KEYBOARD_P1 := -1

## Teclado alternativo do Jogador 2: Setas + teclas J / K.
const KEYBOARD_P2 := -2

# ── Estado global ────────────────────────────────────────────────────────────

var game_mode: GameMode = GameMode.LOCAL_DUO

## Dispositivo do Jogador 1 (-1 = teclado P1, 0+ = índice do joypad).
var player1_device: int = KEYBOARD_P1

## Dispositivo do Jogador 2 (-2 = teclado P2, 0+ = índice do joypad).
var player2_device: int = KEYBOARD_P2

# ── Ciclo de vida ────────────────────────────────────────────────────────────

func _ready() -> void:
	_setup_keyboard_actions()

# ── API pública ──────────────────────────────────────────────────────────────

## Retorna o dispositivo atribuído ao jogador (player_id = 1 ou 2).
func get_player_device(player_id: int) -> int:
	return player1_device if player_id == 1 else player2_device

## Altera o dispositivo de um jogador e reconfigura os eventos de joypad.
func set_player_device(player_id: int, device: int) -> void:
	if player_id == 1:
		player1_device = device
	else:
		player2_device = device
	_rebuild_joypad_events(player_id)

# ── Configuração do InputMap ─────────────────────────────────────────────────

func _setup_keyboard_actions() -> void:
	## Registra todas as ações de teclado/mouse no InputMap.
	## As ações de joypad são adicionadas dinamicamente via set_player_device().

	# ── Jogador 1 (WASD + mouse) ──────────────────────────────────────────────
	_key("p1_left",        KEY_A)
	_key("p1_right",       KEY_D)
	_key("p1_jump",        KEY_W)
	_key("p1_jump",        KEY_SPACE,           true)  # adiciona sem apagar W
	_mouse("p1_attack",    MOUSE_BUTTON_LEFT)
	_mouse("p1_mega_attack", MOUSE_BUTTON_RIGHT)

	# ── Jogador 2 (Setas + J / K) ─────────────────────────────────────────────
	_key("p2_left",        KEY_LEFT)
	_key("p2_right",       KEY_RIGHT)
	_key("p2_jump",        KEY_UP)
	_key("p2_attack",      KEY_J)
	_key("p2_mega_attack", KEY_K)

func _rebuild_joypad_events(player_id: int) -> void:
	## Remove eventos de joypad do grupo de ações do jogador e
	## adiciona os do novo dispositivo (se for um joypad).
	var prefix := "p%d_" % player_id
	var device  := get_player_device(player_id)

	# Remove eventos de joypad existentes
	for suffix in ["left", "right", "jump", "attack", "mega_attack"]:
		var action := prefix + suffix
		if not InputMap.has_action(action):
			continue
		for event in InputMap.action_get_events(action).duplicate():
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				InputMap.action_erase_event(action, event)

	if device < 0:
		return  # teclado — sem eventos de joypad

	# ── Movimento ─────────────────────────────────────────────────────────────
	_joy_axis(prefix + "left",  device, JOY_AXIS_LEFT_X, -1.0)
	_joy_axis(prefix + "right", device, JOY_AXIS_LEFT_X,  1.0)
	_joy_axis(prefix + "jump",  device, JOY_AXIS_LEFT_Y, -1.0)
	_joy_btn(prefix + "left",   device, JOY_BUTTON_DPAD_LEFT)
	_joy_btn(prefix + "right",  device, JOY_BUTTON_DPAD_RIGHT)
	_joy_btn(prefix + "jump",   device, JOY_BUTTON_DPAD_UP)

	# ── Ações ─────────────────────────────────────────────────────────────────
	_joy_btn(prefix + "jump",        device, JOY_BUTTON_A)              # Sul  / A Xbox  / Cruz PS
	_joy_btn(prefix + "attack",      device, JOY_BUTTON_X)              # Oeste / X Xbox / Quadrado PS
	_joy_btn(prefix + "attack",      device, JOY_BUTTON_RIGHT_SHOULDER) # R1
	_joy_btn(prefix + "mega_attack", device, JOY_BUTTON_Y)              # Norte / Y Xbox / Triângulo PS
	_joy_btn(prefix + "mega_attack", device, JOY_BUTTON_LEFT_SHOULDER)  # L1

# ── Helpers privados ─────────────────────────────────────────────────────────

func _key(action: String, key: Key, append: bool = false) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.5)
		append = false
	if not append:
		InputMap.action_erase_events(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.device = -1
	InputMap.action_add_event(action, event)

func _mouse(action: String, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.5)
	else:
		# Remove apenas eventos de mouse (preserva eventuais joypads)
		for ev in InputMap.action_get_events(action).duplicate():
			if ev is InputEventMouseButton:
				InputMap.action_erase_event(action, ev)
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.device = -1
	InputMap.action_add_event(action, event)

func _joy_btn(action: String, device: int, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.5)
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.device = device
	InputMap.action_add_event(action, event)

func _joy_axis(action: String, device: int, axis: JoyAxis, value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.5)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	event.device = device
	InputMap.action_add_event(action, event)
