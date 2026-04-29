extends Node

signal room_loaded(room: Node)
signal room_transition_started
signal room_transition_finished

var current_room: Node = null
var _player: CharacterBody2D = null
var _transitioning: bool = false

func register_player(player: CharacterBody2D) -> void:
	_player = player

func load_room(room_path: String, spawn_position: Vector2 = Vector2.ZERO) -> void:
	if _transitioning:
		return
	_transitioning = true
	room_transition_started.emit()

	await get_tree().create_timer(0.2).timeout

	_unload_current_room()

	var scene: PackedScene = load(room_path)
	if scene == null:
		push_error("RoomManager: could not load room at path: " + room_path)
		_transitioning = false
		return

	current_room = scene.instantiate()
	get_tree().current_scene.add_child(current_room)

	if _player and spawn_position != Vector2.ZERO:
		_player.global_position = spawn_position

	await get_tree().create_timer(0.2).timeout
	_transitioning = false
	room_transition_finished.emit()
	room_loaded.emit(current_room)

func _unload_current_room() -> void:
	if current_room:
		current_room.queue_free()
		current_room = null
