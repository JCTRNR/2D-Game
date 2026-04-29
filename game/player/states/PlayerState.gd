class_name PlayerState
extends Node

var sm: PlayerStateMachine
var player: Player

func _ready() -> void:
	set_process(false)
	set_physics_process(false)

func enter(_params: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
