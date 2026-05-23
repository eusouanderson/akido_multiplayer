## Menu — Tela inicial do jogo.
extends Control

func _ready() -> void:
	$CC/VBox/BtnPlaySolo.pressed.connect(_on_btn_play_solo_pressed)
	$CC/VBox/BtnPlayLocal.pressed.connect(_on_btn_play_local_pressed)
	$CC/VBox/BtnPlayOnline.pressed.connect(_on_btn_play_online_pressed)
	$CC/VBox/BtnSettings.pressed.connect(_on_btn_settings_pressed)
	$CC/VBox/BtnQuit.pressed.connect(_on_btn_quit_pressed)

func _on_btn_play_solo_pressed() -> void:
	GameState.game_mode = GameState.GameMode.SOLO
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_btn_play_local_pressed() -> void:
	GameState.game_mode = GameState.GameMode.LOCAL_DUO
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_btn_play_online_pressed() -> void:
	GameState.game_mode = GameState.GameMode.ONLINE
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_btn_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
