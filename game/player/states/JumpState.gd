class_name JumpState
extends PlayerState

func enter(_params: Dictionary = {}) -> void:
	player.velocity.y = player.JUMP_VELOCITY
	player.jump_buffer_timer = 0.0
	player.coyote_timer = 0.0

func physics_update(delta: float) -> void:
	var inp := player.input

	# Variable jump height — release early to cut ascent
	if inp.jump_released and player.velocity.y < 0.0:
		player.velocity.y *= player.JUMP_RELEASE_MULTIPLIER

	if inp.attack_light:
		sm.transition_to("AttackLightState")
		return

	if inp.attack_heavy:
		sm.transition_to("AttackHeavyState")
		return

	if inp.dodge and GameState.is_unlocked("dodge"):
		sm.transition_to("DodgeState")
		return

	# Transition to fall once velocity flips positive (apex reached)
	if player.velocity.y >= 0.0:
		sm.transition_to("FallState")
		return

	player.apply_gravity(delta, player.JUMP_GRAVITY)
	player.apply_horizontal_movement(delta, player.AIR_ACCELERATION, player.AIR_DECELERATION)
	player.update_facing(inp.move_direction)
