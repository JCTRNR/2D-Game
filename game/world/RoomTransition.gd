class_name RoomTransition
extends Area2D

@export var target_room: String = ""           # res:// path to next room scene
@export var spawn_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	collision_layer = 0
	collision_mask  = 1    # detects layer 1: player
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player and not target_room.is_empty():
		RoomManager.load_room(target_room, spawn_position)
