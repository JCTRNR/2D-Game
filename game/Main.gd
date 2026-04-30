extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $GameCamera
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	add_to_group("main")

	if camera.has_method("set_target"):
		camera.set_target(player)

	if hud.has_method("set_player"):
		hud.set_player(player)

	RoomManager.register_player(player)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_reset"):
		get_tree().reload_current_scene()