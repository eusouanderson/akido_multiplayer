extends Control

func _ready() -> void:
	# Carrega o volume salvo (padrão 1.0 se não houver nada salvo)
	var master_vol = ProjectSettings.get_setting("akido/master_volume", 1.0)
	$CenterContainer/VBoxContainer/MasterVolContainer/MasterVolSlider.value = master_vol

	$CenterContainer/VBoxContainer/MasterVolContainer/MasterVolSlider.value_changed.connect(_on_master_vol_changed)
	$CenterContainer/VBoxContainer/FullscreenCheck.toggled.connect(_on_fullscreen_toggled)
	$CenterContainer/VBoxContainer/BtnBack.pressed.connect(_on_btn_back_pressed)

	# Reflete o estado atual de tela cheia
	$CenterContainer/VBoxContainer/FullscreenCheck.button_pressed = \
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_master_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
