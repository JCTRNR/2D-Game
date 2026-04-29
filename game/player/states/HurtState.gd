class_name HurtState
extends PlayerState

const DURATION := 0.50

var _timer: float = 0.0

func enter(params: Dictionary = {}) -> void:
	_timer = 0.0
	var knockback: Vector2 = params.get("knockback", Vector2.ZERO)
	player.velocity = knockback

func physics_update(delta: float) -> void:
	_timer += delta
	player.apply_gravity(delta, player.FALL_GRAVITY)

	# Friction during hurt to slow knockback
	player.velocity.x = move_toward(player.velocity.x, 0.0, 800.0 * delta)

	if _timer >= DURATION:
		if player.health.is_dead():
			sm.transition_to("DeadState")
		else:
			sm.transition_to("IdleState" if player.is_on_floor() else "FallState")
