class_name FallState
extends PlayerState

func physics_update(delta: float) -> void:
	var inp := player.input

	if player.is_on_floor():
		sm.transition_to("IdleState")
		return

	# Coyote jump
	if inp.jump_pressed and player.coyote_timer > 0.0:
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

	var gravity := player.FAST_FALL_GRAVITY if inp.fast_fall else player.FALL_GRAVITY
	player.apply_gravity(delta, gravity)
	player.apply_horizontal_movement(delta, player.AIR_ACCELERATION, player.AIR_DECELERATION)
	player.update_facing(inp.move_direction)
