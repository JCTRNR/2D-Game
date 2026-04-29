class_name EnemyChaseState
extends EnemyState

const CHASE_SPEED   := 160.0
const ATTACK_RANGE  := 90.0
const LOSE_RANGE    := 600.0

var _attack_cooldown: float = 0.0

func enter(params: Dictionary = {}) -> void:
	_attack_cooldown = params.get("attack_cooldown", 0.0)

func update(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta

func physics_update(delta: float) -> void:
	if not enemy.is_on_floor():
		enemy.apply_gravity(delta)

	var player := enemy.get_player()
	if player == null:
		sm.transition_to("EnemyIdleState")
		return

	var dist := enemy.global_position.distance_to(player.global_position)

	if dist > LOSE_RANGE:
		sm.transition_to("EnemyIdleState")
		return

	if dist <= ATTACK_RANGE and _attack_cooldown <= 0.0:
		sm.transition_to("EnemyAttackState")
		return

	var dir := sign(player.global_position.x - enemy.global_position.x)
	enemy.velocity.x = dir * CHASE_SPEED
	enemy.update_facing(dir)
