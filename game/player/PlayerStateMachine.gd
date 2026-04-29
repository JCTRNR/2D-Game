class_name PlayerStateMachine
extends Node

var states: Dictionary = {}
var current_state: PlayerState = null

func _ready() -> void:
	await get_parent().ready
	for child in get_children():
		if child is PlayerState:
			states[child.name] = child
			child.sm = self
			child.player = get_parent() as Player

func transition_to(state_name: String, params: Dictionary = {}) -> void:
	var next: PlayerState = states.get(state_name)
	if next == null:
		push_error("PlayerStateMachine: unknown state '" + state_name + "'")
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
	# Flush one-shot inputs after every physics tick so presses are never missed
	var p := get_parent() as Player
	if p and p.input:
		p.input.flush()

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
