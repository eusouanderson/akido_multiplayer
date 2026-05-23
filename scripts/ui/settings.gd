## Settings — Tela de configurações gerais.
extends Control

func _ready() -> void:
	var master_vol: float = ProjectSettings.get_setting("akido/master_volume", 1.0)
	$CC/VBox/MasterVolRow/MasterVolSlider.value = master_vol

	$CC/VBox/MasterVolRow/MasterVolSlider.value_changed.connect(_on_master_vol_changed)
	$CC/VBox/FullscreenCheck.toggled.connect(_on_fullscreen_toggled)
	$CC/VBox/BtnControls.pressed.connect(_on_btn_controls_pressed)
	$CC/VBox/BtnBack.pressed.connect(_on_btn_back_pressed)

	$CC/VBox/FullscreenCheck.button_pressed = \
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_master_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on \
	            else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _on_btn_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/controls.tscn")

func _on_btn_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
