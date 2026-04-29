class_name HealthComponent
extends Node

# Hit-based segment health (Hollow Knight masks style).
# max_health = number of segments.

@export var max_health: int = 5

var current_health: int

signal health_changed(current: int, maximum: int)
signal died

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0
