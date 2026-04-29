extends Node2D

func _ready() -> void:
	RoomManager.load_room(
		GameState.last_checkpoint_room,
		GameState.last_checkpoint_position
	)
