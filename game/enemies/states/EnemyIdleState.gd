class_name EnemyIdleState
extends EnemyState

const IDLE_DURATION := 1.5

var _timer: float = 0.0

func enter(_params: Dictionary = {}) -> void:
	_timer = 0.0
	enemy.velocity = Vector2.ZERO

func physics_update(delta: float) -> void:
	_timer += delta

	if not enemy.is_on_floor():
		enemy.apply_gravity(delta)

	if enemy.can_see_player():
		sm.transition_to("EnemyChaseState")
		return

	if _timer >= IDLE_DURATION:
		sm.transition_to("EnemyPatrolState")
