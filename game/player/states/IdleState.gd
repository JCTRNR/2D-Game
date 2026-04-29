class_name IdleState
extends PlayerState

func enter(_params: Dictionary = {}) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0.0, 100.0)

func physics_update(_delta: float) -> void:
	var inp := player.input

	if not player.is_on_floor():
		sm.transition_to("FallState")
		return

	if inp.jump_pressed or player.jump_buffer_timer > 0.0:
		sm.transition_to("JumpState")
		return

	if inp.attack_light:
		sm.transition_to("AttackLightState")
		return

	if inp.attack_heavy:
		sm.transition_to("AttackHeavyState")
		return

	if inp.dodge and GameState.is_unlocked("dodge"):
		sm.transition_to("DodgeState")
		return

	if not is_zero_approx(inp.move_direction):
		sm.transition_to("MoveState")
		return
