## Testes do GameState — singleton global de estado da partida.
extends Object

var runner

func run_all() -> void:
	test_game_mode_enum()
	test_keyboard_constants()
	test_device_padrao()
	test_get_player_device()
	test_set_player_device()
	test_inputmap_acoes_p1()
	test_inputmap_acoes_p2()

# ── Enums e constantes ──────────────────────────────────────────
func test_game_mode_enum() -> void:
	runner.assert_eq(GameState.GameMode.SOLO,      1, "GameMode.SOLO = 1")
	runner.assert_eq(GameState.GameMode.LOCAL_DUO, 2, "GameMode.LOCAL_DUO = 2")
	runner.assert_eq(GameState.GameMode.ONLINE,    3, "GameMode.ONLINE = 3")

func test_keyboard_constants() -> void:
	runner.assert_eq(GameState.KEYBOARD_P1, -1, "KEYBOARD_P1 = -1")
	runner.assert_eq(GameState.KEYBOARD_P2, -2, "KEYBOARD_P2 = -2")

# ── Estado padrão ───────────────────────────────────────────────
func test_device_padrao() -> void:
	runner.assert_eq(GameState.player1_device, GameState.KEYBOARD_P1,
		"player1_device padrão = KEYBOARD_P1")
	runner.assert_eq(GameState.player2_device, GameState.KEYBOARD_P2,
		"player2_device padrão = KEYBOARD_P2")

# ── API pública ─────────────────────────────────────────────────
func test_get_player_device() -> void:
	runner.assert_eq(GameState.get_player_device(1), GameState.player1_device,
		"get_player_device(1) retorna player1_device")
	runner.assert_eq(GameState.get_player_device(2), GameState.player2_device,
		"get_player_device(2) retorna player2_device")

func test_set_player_device() -> void:
	var original1 := GameState.player1_device
	var original2 := GameState.player2_device

	GameState.set_player_device(1, 0)   # simula joypad 0
	runner.assert_eq(GameState.player1_device, 0,
		"set_player_device(1, 0) altera player1_device para joypad 0")

	GameState.set_player_device(2, 1)   # simula joypad 1
	runner.assert_eq(GameState.player2_device, 1,
		"set_player_device(2, 1) altera player2_device para joypad 1")

	# Restaura estado original para não quebrar testes seguintes
	GameState.set_player_device(1, original1)
	GameState.set_player_device(2, original2)
	runner.assert_eq(GameState.player1_device, original1, "player1_device restaurado")
	runner.assert_eq(GameState.player2_device, original2, "player2_device restaurado")

# ── InputMap ─────────────────────────────────────────────────────
func test_inputmap_acoes_p1() -> void:
	for suffix: String in ["left", "right", "jump", "attack", "mega_attack"]:
		var action: String = "p1_" + suffix
		runner.assert_true(InputMap.has_action(action),
			"InputMap tem ação '%s'" % action)

func test_inputmap_acoes_p2() -> void:
	for suffix: String in ["left", "right", "jump", "attack", "mega_attack"]:
		var action: String = "p2_" + suffix
		runner.assert_true(InputMap.has_action(action),
			"InputMap tem ação '%s'" % action)
