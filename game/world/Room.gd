class_name Room
extends Node2D

@export var room_width: float  = 2560.0
@export var room_height: float = 1080.0
@export var spawn_position: Vector2 = Vector2(200.0, 900.0)

func _ready() -> void:
	_apply_camera_bounds.call_deferred()

func _apply_camera_bounds() -> void:
	var cam := get_tree().get_first_node_in_group("camera") as GameCamera
	if cam == null:
		return
	cam.set_room_bounds(0.0, room_width, 0.0, room_height)
