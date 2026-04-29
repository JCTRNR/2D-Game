class_name EnemyStateMachine
extends Node

var states: Dictionary = {}
var current_state: EnemyState = null

func _ready() -> void:
	await get_parent().ready
	for child in get_children():
		if child is EnemyState:
			states[child.name] = child
			child.sm = self
			child.enemy = get_parent() as EnemyBase

func transition_to(state_name: String, params: Dictionary = {}) -> void:
	var next: EnemyState = states.get(state_name)
	if next == null:
		push_error("EnemyStateMachine: unknown state '" + state_name + "'")
		return
	if next == current_state:
		return
	if current_state:
		current_state.exit()
	current_state = next
	current_state.enter(params)

func start(initial_state: String) -> void:
	current_state = states.get(initial_state)
	if current_state:
		current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
