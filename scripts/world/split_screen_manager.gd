## SplitScreenManager — Câmera dinâmica e split-screen para o modo LOCAL_DUO.
##
## • Modo unificado: uma câmera segue o ponto médio entre os dois jogadores.
## • Modo split   : dois SubViewports lado a lado, cada um com câmera própria,
##                  compartilhando o mesmo World2D da cena principal.
##
## A transição usa histerese para evitar flickering na distância-limite.
class_name SplitScreenManager
extends Node

# ── Constantes ───────────────────────────────────────────────────────────────

## Distância (world units) para ativar o split-screen.
const SPLIT_DISTANCE: float  = 320.0

## Distância para voltar ao modo unificado (histerese).
const MERGE_DISTANCE: float  = 230.0

## Zoom da câmera no modo unificado.
const ZOOM_SINGLE: Vector2   = Vector2(3.0, 3.0)

## Zoom das câmeras no modo split (um pouco mais aberto para cada metade).
const ZOOM_SPLIT: Vector2    = Vector2(2.2, 2.2)

## Espessura da linha divisória entre as telas (px).
const DIVIDER_PX: int        = 3

# ── Referências da cena principal ────────────────────────────────────────────

var _player1: CharacterBody2D
var _player2: CharacterBody2D
var _main_camera: Camera2D
var _main_bg_layer: CanvasLayer   ## CanvasLayer do ParallaxBackground

# ── Nós criados em runtime ───────────────────────────────────────────────────

var _vp1: SubViewport
var _vp2: SubViewport
var _cam1: Camera2D
var _cam2: Camera2D
var _screen_layer: CanvasLayer
var _split_root: Control

var _is_split: bool    = false
## Sinaliza que _ready() terminou (incluindo o await).
## _process() ignora frames enquanto ainda estiver inicializando.
var _initialized: bool = false

# ── Ciclo de vida ────────────────────────────────────────────────────────────

func _ready() -> void:
	# Aguarda um frame para a cena pai estar completamente pronta
	await get_tree().process_frame

	var root := get_parent()
	_player1       = root.get_node("MultiplayerSynchronizer/Player1")
	_player2       = root.get_node("MultiplayerSynchronizer/Player2")
	_main_camera   = root.get_node("MultiplayerSynchronizer/Camera2D")
	_main_bg_layer = root.get_node_or_null("CanvasLayer")

	# Desativa RemoteTransform2Ds — assumimos controle total das câmeras
	_player1.get_node("RemoteTransform2D").remote_path = NodePath("")
	_player2.get_node("RemoteTransform2D").remote_path = NodePath("")

	# Reconfigura a câmera principal para modo unificado
	_main_camera.zoom                       = ZOOM_SINGLE
	_main_camera.position_smoothing_enabled = true
	_main_camera.position_smoothing_speed   = 8.0
	_main_camera.drag_horizontal_enabled    = false
	_main_camera.drag_vertical_enabled      = false
	_main_camera.enabled                    = true

	_build_split_ui()
	_set_split(false)
	_initialized = true   # só aqui _process() pode rodar com segurança

# ── Construção da UI de split ────────────────────────────────────────────────

func _build_split_ui() -> void:
	var vp_rect: Rect2i = get_viewport().get_visible_rect()
	var vp_w: int = vp_rect.size.x
	var vp_h: int = vp_rect.size.y
	var half_w: int = (vp_w - DIVIDER_PX) / 2

	# CanvasLayer que hospeda os contêineres (acima do jogo, abaixo do HUD)
	_screen_layer = CanvasLayer.new()
	_screen_layer.layer = 2
	get_parent().add_child(_screen_layer)

	_split_root = Control.new()
	_split_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_layer.add_child(_split_root)

	# Cria os dois SubViewports compartilhando o World2D da cena
	_vp1 = _make_viewport(Vector2i(half_w, vp_h))
	_vp2 = _make_viewport(Vector2i(half_w, vp_h))
	get_parent().add_child(_vp1)
	get_parent().add_child(_vp2)

	# Câmeras dentro de cada SubViewport
	_cam1 = _make_camera(_vp1)
	_cam2 = _make_camera(_vp2)

	# Container horizontal: [VP1] [divisória] [VP2]
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	_split_root.add_child(hbox)

	hbox.add_child(_make_vp_container(_vp1))

	var divider := ColorRect.new()
	divider.color = Color(0.0, 0.0, 0.0, 1.0)
	divider.custom_minimum_size = Vector2(DIVIDER_PX, 0)
	divider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(divider)

	hbox.add_child(_make_vp_container(_vp2))

	# Redimensiona os SubViewports quando a janela muda
	get_viewport().size_changed.connect(_on_viewport_resized)

func _make_viewport(sz: Vector2i) -> SubViewport:
	var vp := SubViewport.new()
	vp.size                     = sz
	vp.own_world_2d             = false   # Compartilha física e canvas com a cena principal
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.handle_input_locally     = false
	vp.transparent_bg           = false

	# Fundo sólido (o ParallaxBackground está em CanvasLayer da cena principal
	# e não é visível em SubViewports — usamos uma cor aproximada do cenário)
	var bg_layer := CanvasLayer.new()
	bg_layer.layer = -100
	vp.add_child(bg_layer)

	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.05, 0.10, 1.0)   # roxo-escuro, compatível com o mapa
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.anchor_right  = 1.0
	bg.anchor_bottom = 1.0
	bg_layer.add_child(bg)

	return vp

func _make_camera(vp: SubViewport) -> Camera2D:
	var cam := Camera2D.new()
	cam.zoom                       = ZOOM_SPLIT
	# Offset vertical idêntico ao da câmera principal (offset.y = -36 no game.tscn):
	# desloca a visão para cima, fazendo o player aparecer no terço inferior da tela.
	cam.offset                     = Vector2(0.0, -36.0)
	# Smoothing desativado aqui: a suavização é feita via lerp manual em _update_cameras
	# para evitar conflito com o global_position setado a cada frame.
	cam.position_smoothing_enabled = false
	cam.drag_horizontal_enabled    = false
	cam.drag_vertical_enabled      = false
	vp.add_child(cam)
	cam.make_current()   # garante que esta câmera está ativa no SubViewport
	return cam

func _make_vp_container(vp: SubViewport) -> SubViewportContainer:
	var c := SubViewportContainer.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	c.stretch               = true
	c.add_child(vp)
	return c

# ── Loop de atualização ──────────────────────────────────────────────────────

func _process(delta: float) -> void:
	# Aguarda o await do _ready() terminar antes de acessar qualquer nó.
	# Sem esse guard, _process() roda no frame seguinte ao await com _cam1/2 = null.
	if not _initialized:
		return
	if not is_instance_valid(_player1) or not is_instance_valid(_player2):
		return

	var dist: float = _player1.global_position.distance_to(_player2.global_position)

	if not _is_split and dist > SPLIT_DISTANCE:
		_set_split(true)
	elif _is_split and dist < MERGE_DISTANCE:
		_set_split(false)

	_update_cameras(delta)

func _update_cameras(delta: float) -> void:
	var p1: Vector2 = _player1.global_position
	var p2: Vector2 = _player2.global_position

	if _is_split:
		# lerp manual independente de frame rate: câmera segue o player suavemente
		# sem conflitar com o position_smoothing interno do Camera2D.
		var t: float = clamp(12.0 * delta, 0.0, 1.0)
		_cam1.global_position = _cam1.global_position.lerp(p1, t)
		_cam2.global_position = _cam2.global_position.lerp(p2, t)
	else:
		# Câmera principal segue o ponto médio (o smoothing interno dela já suaviza)
		_main_camera.global_position = (p1 + p2) * 0.5

# ── Alternância de modo ──────────────────────────────────────────────────────

func _set_split(split: bool) -> void:
	_is_split = split

	if split:
		# Ativa split-screen
		_split_root.show()
		_main_camera.enabled = false
		if is_instance_valid(_main_bg_layer):
			_main_bg_layer.hide()
	else:
		# Volta ao modo unificado
		_split_root.hide()
		_main_camera.enabled = true
		if is_instance_valid(_main_bg_layer):
			_main_bg_layer.show()

		# Snap imediato para evitar salto de câmera ao mesclar:
		# usa a posição ATUAL das câmeras de split (que já estão próximas dos players)
		# para iniciar a câmera principal já no lugar certo.
		var mid: Vector2 = (_cam1.global_position + _cam2.global_position) * 0.5
		_main_camera.position_smoothing_enabled = false
		_main_camera.global_position            = mid
		_main_camera.position_smoothing_enabled = true

# ── Redimensionamento ────────────────────────────────────────────────────────

func _on_viewport_resized() -> void:
	var vp_rect: Rect2i = get_viewport().get_visible_rect()
	var vp_w: int = vp_rect.size.x
	var vp_h: int = vp_rect.size.y
	var half_w: int = (vp_w - DIVIDER_PX) / 2
	_vp1.size = Vector2i(half_w, vp_h)
	_vp2.size = Vector2i(half_w, vp_h)
