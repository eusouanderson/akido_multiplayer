## PauseMenu — Menu de pausa exibido ao pressionar ESC durante o jogo.
##
## Gerencia: pausar/retomar o jogo, voltar ao menu principal e sair.
## process_mode = ALWAYS garante que o input é lido mesmo com a árvore pausada.
extends CanvasLayer

# ── Sinais ───────────────────────────────────────────────────────────────────

## Emitido quando o jogador escolhe voltar ao menu principal.
signal main_menu_requested

# ── Ciclo de vida ────────────────────────────────────────────────────────────

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	$BG/Center/Panel/Margin/VBox/BtnContinuar.pressed.connect(_on_continuar_pressed)
	$BG/Center/Panel/Margin/VBox/BtnMenuPrincipal.pressed.connect(_on_menu_principal_pressed)
	$BG/Center/Panel/Margin/VBox/BtnSair.pressed.connect(_on_sair_pressed)

# ── Input ────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	# is_action_pressed(action, allow_echo=false) já ignora tecla mantida pressionada
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

# ── Lógica de pausa ──────────────────────────────────────────────────────────

func _toggle_pause() -> void:
	if get_tree().paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	get_tree().paused = true
	show()

func _resume() -> void:
	get_tree().paused = false
	hide()

# ── Callbacks dos botões ─────────────────────────────────────────────────────

func _on_continuar_pressed() -> void:
	_resume()

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	emit_signal("main_menu_requested")

func _on_sair_pressed() -> void:
	get_tree().quit()
