class_name StaggerComponent
extends Node

@export var max_stagger: float = 100.0
@export var recovery_rate: float = 25.0   # per second, drains passively
@export var stagger_duration: float = 0.6 # seconds the stagger state lasts

var current_stagger: float = 0.0
var _stagger_cooldown: float = 0.0        # brief window after stagger before bar recovers

signal stagger_changed(current: float, maximum: float)
signal staggered

func _process(delta: float) -> void:
	if _stagger_cooldown > 0.0:
		_stagger_cooldown -= delta
		return
	if current_stagger > 0.0:
		current_stagger = max(0.0, current_stagger - recovery_rate * delta)
		stagger_changed.emit(current_stagger, max_stagger)

func add_stagger(amount: float) -> void:
	current_stagger = min(current_stagger + amount, max_stagger)
	stagger_changed.emit(current_stagger, max_stagger)
	if current_stagger >= max_stagger:
		current_stagger = 0.0
		_stagger_cooldown = stagger_duration
		staggered.emit()
