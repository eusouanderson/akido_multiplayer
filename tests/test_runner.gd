## Test Runner para o Akido Multiplayer
## Execute via: flatpak run org.godotengine.Godot --path . --headless -- --script tests/test_runner.gd
extends SceneTree

const COLOR_OK    = "[32m"  # verde
const COLOR_FAIL  = "[31m"  # vermelho
const COLOR_RESET = "[0m"
const COLOR_TITLE = "[36m"  # ciano

var _passed := 0
var _failed := 0
var _total  := 0

func _initialize() -> void:
	print("\n%s═══ AKIDO MULTIPLAYER — TESTES DE MENU ═══%s\n" % [COLOR_TITLE, COLOR_RESET])

	run_suite("Menu Principal",    preload("res://tests/test_menu.gd").new())
	run_suite("Configurações",     preload("res://tests/test_settings.gd").new())
	run_suite("Lobby Online",      preload("res://tests/test_lobby.gd").new())

	print("\n%s───────────────────────────────────%s" % [COLOR_TITLE, COLOR_RESET])
	var status_color = COLOR_OK if _failed == 0 else COLOR_FAIL
	print("%s✔ Passou: %d  ✘ Falhou: %d  Total: %d%s\n" % [
		status_color, _passed, _failed, _total, COLOR_RESET
	])

	quit(0 if _failed == 0 else 1)

func run_suite(suite_name: String, suite: Object) -> void:
	print("%s▶ %s%s" % [COLOR_TITLE, suite_name, COLOR_RESET])
	suite.runner = self
	suite.run_all()
	suite.free()
	print("")

func assert_true(cond: bool, msg: String) -> void:
	_total += 1
	if cond:
		_passed += 1
		print("  %s✔%s %s" % [COLOR_OK, COLOR_RESET, msg])
	else:
		_failed += 1
		print("  %s✘%s %s" % [COLOR_FAIL, COLOR_RESET, msg])

func assert_false(cond: bool, msg: String) -> void:
	assert_true(not cond, msg)

func assert_not_null(val, msg: String) -> void:
	assert_true(val != null, msg)

func assert_eq(a, b, msg: String) -> void:
	assert_true(a == b, "%s  (esperado: %s, obtido: %s)" % [msg, str(b), str(a)])
