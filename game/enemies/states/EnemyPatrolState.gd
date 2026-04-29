class_name EnemyPatrolState
extends EnemyState

const PATROL_SPEED    := 100.0
const PATROL_DISTANCE := 200.0  # pixels from spawn before turning

var _start_x: float = 0.0
var _direction: float = 1.0

func enter(_params: Dictionary = {}) -> void:
	_start_x   = enemy.global_position.x
	_direction = 1.0
	enemy.facing = _direction

func physics_update(delta: float) -> void:
	if not enemy.is_on_floor():
		enemy.apply_gravity(delta)

	if enemy.can_see_player():
		sm.transition_to("EnemyChaseState")
		return

	# Turn at patrol edges or walls
	var dist := enemy.global_position.x - _start_x
	if enemy.is_on_wall() or abs(dist) >= PATROL_DISTANCE:
		_direction *= -1.0
		enemy.facing = _direction

	enemy.velocity.x = _direction * PATROL_SPEED
	enemy.update_facing(_direction)
