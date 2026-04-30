extends CanvasLayer

var player: Node

var _health_display: HealthDisplay
var _debug_label: Label
var _controls_label: Label

func _ready() -> void:
	_build_ui()

func set_player(new_player: Node) -> void:
	player = new_player
	if player == null:
		return

	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)

	# Seed initial display from HealthComponent if available
	if "health" in player and player.health != null:
		var h: HealthComponent = player.health
		_health_display.setup(h.max_health)
		_health_display.update_health(h.current_health, h.max_health)

func _process(_delta: float) -> void:
	if player != null and player.has_method("get_debug_text"):
		_debug_label.text = player.get_debug_text()

func _build_ui() -> void:
	var root := Control.new()
	root.name = "HUDRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Hollow Knight-style HP segments
	_health_display          = HealthDisplay.new()
	_health_display.name     = "HealthDisplay"
	_health_display.position = Vector2(24, 24)
	root.add_child(_health_display)

	_debug_label = Label.new()
	_debug_label.name     = "DebugLabel"
	_debug_label.position = Vector2(24, 72)
	_debug_label.add_theme_font_size_override("font_size", 18)
	_debug_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.55))
	root.add_child(_debug_label)

	_controls_label = Label.new()
	_controls_label.name     = "ControlsLabel"
	_controls_label.position = Vector2(24, 930)
	_controls_label.add_theme_font_size_override("font_size", 20)
	_controls_label.text = "A/D move  |  Space jump  |  S fast-fall  |  LMB light  |  RMB heavy  |  Shift dodge  |  R reset"
	root.add_child(_controls_label)

func _on_player_health_changed(current: int, max_value: int) -> void:
	if _health_display.segment_count() != max_value:
		_health_display.setup(max_value)
	_health_display.update_health(current, max_value)
