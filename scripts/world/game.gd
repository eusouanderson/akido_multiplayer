## Game — Script raiz da cena de jogo.
##
## • Instancia o menu de pausa (todos os modos).
## • Em SOLO   : desativa o RemoteTransform2D do Player2 (evita conflito de câmera).
## • Em LOCAL_DUO: instancia o SplitScreenManager que controla câmera e split-screen.
extends Node2D

# ── Constantes ───────────────────────────────────────────────────────────────
const PAUSE_MENU_SCENE: PackedScene = preload("res://scenes/pause_menu.tscn")

# ── Ciclo de vida ────────────────────────────────────────────────────────────

func _ready() -> void:
	# ── Menu de pausa ─────────────────────────────────────────────────────────
	var pause_menu: CanvasLayer = PAUSE_MENU_SCENE.instantiate()
	pause_menu.main_menu_requested.connect(_on_main_menu_requested)
	add_child(pause_menu)

	# ── Câmera por modo de jogo ───────────────────────────────────────────────
	match GameState.game_mode:
		GameState.GameMode.SOLO:
			# Player2 tem um RemoteTransform2D que sobrescreveria a câmera do P1.
			# No modo Solo, Player2 não é controlado — desativa o transform.
			var rt2: RemoteTransform2D = $MultiplayerSynchronizer/Player2/RemoteTransform2D
			rt2.remote_path = NodePath("")

		GameState.GameMode.LOCAL_DUO:
			# SplitScreenManager assume controle total das câmeras e cria
			# o split-screen quando os jogadores se separam.
			add_child(SplitScreenManager.new())

# ── Callbacks ────────────────────────────────────────────────────────────────

func _on_main_menu_requested() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
