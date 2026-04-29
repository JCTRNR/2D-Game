class_name EnemyState
extends Node

var sm: EnemyStateMachine
var enemy: EnemyBase

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
