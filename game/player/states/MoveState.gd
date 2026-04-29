class_name MoveState
extends PlayerState

func physics_update(delta: float) -> void:
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

	if is_zero_approx(inp.move_direction):
		sm.transition_to("IdleState")
		return

	player.apply_horizontal_movement(delta, player.ACCELERATION, player.DECELERATION)
	player.update_facing(inp.move_direction)
