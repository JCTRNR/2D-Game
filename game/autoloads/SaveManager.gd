extends Node

# Save system stub — not implemented yet.
# Triggered by story events or rest points.
# Connect signals here when ready to implement.

func save_checkpoint(room_path: String, position: Vector2) -> void:
	GameState.last_checkpoint_room = room_path
	GameState.last_checkpoint_position = position

func load_checkpoint() -> void:
	RoomManager.load_room(
		GameState.last_checkpoint_room,
		GameState.last_checkpoint_position
	)
