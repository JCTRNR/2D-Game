extends Camera2D

@export var follow_speed: float = 9.0
@export var look_ahead_distance: float = 120.0
@export var vertical_offset: float = -120.0
@export var min_x: float = -300.0
@export var max_x: float = 2400.0
@export var min_y: float = -500.0
@export var max_y: float = 1000.0

var target: Node2D

func _ready() -> void:
	make_current()
	position_smoothing_enabled = false
	zoom = Vector2(1.0, 1.0)

func set_room_bounds(x_min: float, x_max: float, y_min: float, y_max: float) -> void:
	min_x = x_min
	max_x = x_max
	min_y = y_min
	max_y = y_max

func set_target(new_target: Node2D) -> void:
	target = new_target
	if target != null:
		global_position = _get_target_position()

func _process(delta: float) -> void:
	if target == null:
		return

	var desired := _get_target_position()
	global_position = global_position.lerp(desired, 1.0 - exp(-follow_speed * delta))

func _get_target_position() -> Vector2:
	var look_ahead := 0.0

	if "facing" in target:
		look_ahead = target.facing * look_ahead_distance

	var desired := target.global_position + Vector2(look_ahead, vertical_offset)

	desired.x = clamp(desired.x, min_x, max_x)
	desired.y = clamp(desired.y, min_y, max_y)

	return desired