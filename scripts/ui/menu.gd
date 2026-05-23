extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnPlayLocal.pressed.connect(_on_btn_play_local_pressed)
	$CenterContainer/VBoxContainer/BtnPlayOnline.pressed.connect(_on_btn_play_online_pressed)
	$CenterContainer/VBoxContainer/BtnSettings.pressed.connect(_on_btn_settings_pressed)
	$CenterContainer/VBoxContainer/BtnQuit.pressed.connect(_on_btn_quit_pressed)

func _on_btn_play_local_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_btn_play_online_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_btn_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
