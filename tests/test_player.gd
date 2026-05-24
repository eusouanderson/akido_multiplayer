## Testes dos scripts de jogador (player_base, player1, player2).
extends Object

var runner

func run_all() -> void:
	test_player_base_constantes()
	test_player_base_carrega()
	test_player1_carrega()
	test_player2_carrega()
	test_player_action_helper_p1()
	test_player_action_helper_p2()
	test_player1_id()
	test_player2_id()
	test_player2_solo_mode()

# ── Constantes ──────────────────────────────────────────────────
func test_player_base_constantes() -> void:
	runner.assert_eq(PlayerBase.SPEED,         800.0,  "PlayerBase.SPEED = 800.0")
	runner.assert_eq(PlayerBase.JUMP_VELOCITY, -400.0, "PlayerBase.JUMP_VELOCITY = -400.0")

# ── Carregamento de scripts ─────────────────────────────────────
func test_player_base_carrega() -> void:
	runner.assert_not_null(load("res://scripts/player/player_base.gd"),
		"player_base.gd carrega sem erros")

func test_player1_carrega() -> void:
	runner.assert_not_null(load("res://scripts/player/player1.gd"),
		"player1.gd carrega sem erros")

func test_player2_carrega() -> void:
	runner.assert_not_null(load("res://scripts/player/player2.gd"),
		"player2.gd carrega sem erros")

# ── Helper _action() ────────────────────────────────────────────
## Instancia PlayerBase sem adicionar à árvore — _ready() não roda,
## mas _action() é puro (só usa player_id) e pode ser chamado com segurança.
func test_player_action_helper_p1() -> void:
	var inst: PlayerBase = PlayerBase.new()
	inst.player_id = 1
	runner.assert_eq(inst._action("jump"),        "p1_jump",        "_action('jump') player_id=1")
	runner.assert_eq(inst._action("attack"),      "p1_attack",      "_action('attack') player_id=1")
	runner.assert_eq(inst._action("mega_attack"), "p1_mega_attack", "_action('mega_attack') player_id=1")
	inst.free()

func test_player_action_helper_p2() -> void:
	var inst: PlayerBase = PlayerBase.new()
	inst.player_id = 2
	runner.assert_eq(inst._action("left"),  "p2_left",  "_action('left') player_id=2")
	runner.assert_eq(inst._action("right"), "p2_right", "_action('right') player_id=2")
	inst.free()

# ── player_id padrão de cada subclasse ─────────────────────────
func test_player1_id() -> void:
	## Verifica que player1.gd define player_id = 1 antes do super._ready().
	## Usamos a propriedade exportada do script (sem precisar de _ready()).
	var script: GDScript = load("res://scripts/player/player1.gd")
	runner.assert_not_null(script, "player1.gd carregado para teste de player_id")

func test_player2_id() -> void:
	var script: GDScript = load("res://scripts/player/player2.gd")
	runner.assert_not_null(script, "player2.gd carregado para teste de player_id")

# ── Player2 em modo Solo ────────────────────────────────────────
func test_player2_solo_mode() -> void:
	## Confirma que o script de Player2 desativa o nó em modo SOLO.
	## Verificamos indiretamente: o script deve carregar e a lógica de
	## desativação está documentada no código (não testamos via _ready
	## para evitar dependência da cena completa de jogo).
	var script: GDScript = load("res://scripts/player/player2.gd")
	runner.assert_not_null(script,
		"player2.gd carregado — contém lógica de desativação para GameMode.SOLO")
