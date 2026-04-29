class_name GameCamera
extends Camera2D

const LERP_SPEED      := 5.0
const LOOK_AHEAD_DIST := 120.0
const DEAD_ZONE       := 40.0

var _target: Node2D = null
var _look_ahead: float = 0.0

func _ready() -> void:
	add_to_group("camera")
	position_smoothing_enabled = false
	drag_horizontal_enabled    = false
	drag_vertical_enabled      = false
	# Auto-find player — waits one frame so Player._ready() has run
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		set_target(player)

func set_target(node: Node2D) -> void:
	_target = node
	if _target:
		global_position = _target.global_position

func set_room_bounds(left: float, right: float, top_y: float, bottom: float) -> void:
	limit_left   = int(left)
	limit_right  = int(right)
	limit_top    = int(top_y)
	limit_bottom = int(bottom)

func _process(delta: float) -> void:
	if _target == null:
		return

	var player := _target as Player
	if player:
		var target_look := player.facing * LOOK_AHEAD_DIST
		_look_ahead = lerp(_look_ahead, target_look, 8.0 * delta)

	var target_pos := _target.global_position + Vector2(_look_ahead, 0.0)
	global_position = global_position.lerp(target_pos, LERP_SPEED * delta)
