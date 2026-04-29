class_name EnemyStaggerState
extends EnemyState

var _timer: float = 0.0

func enter(params: Dictionary = {}) -> void:
	_timer = enemy.stagger.stagger_duration
	var kb: Vector2 = params.get("knockback", Vector2.ZERO)
	# Flip knockback so it pushes enemy away from player
	enemy.velocity = Vector2(-kb.x * 0.4, kb.y * 0.3)
	enemy.hitbox.deactivate()

func physics_update(delta: float) -> void:
	_timer -= delta
	enemy.apply_gravity(delta)
	enemy.velocity.x = move_toward(enemy.velocity.x, 0.0, 600.0 * delta)

	if _timer <= 0.0:
		if enemy.health.is_dead():
			sm.transition_to("EnemyDeadState")
		else:
			sm.transition_to("EnemyChaseState")
