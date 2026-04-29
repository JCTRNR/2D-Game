class_name EnemyAttackState
extends EnemyState

const TOTAL_DURATION := 0.70
const ACTIVE_START   := 0.20
const ACTIVE_END     := 0.40
const ATTACK_COOLDOWN := 1.20

var _timer: float = 0.0

func enter(_params: Dictionary = {}) -> void:
	_timer = 0.0
	enemy.velocity.x = 0.0

func exit() -> void:
	enemy.hitbox.deactivate()

func physics_update(delta: float) -> void:
	_timer += delta

	if _timer >= ACTIVE_START and _timer < ACTIVE_END:
		if not enemy.hitbox.monitoring:
			var dir := enemy.facing
			var hit := HitData.make_light(1, 35.0, Vector2(250.0 * dir, -80.0), enemy)
			enemy.hitbox.activate(hit)
	elif _timer >= ACTIVE_END:
		enemy.hitbox.deactivate()

	if not enemy.is_on_floor():
		enemy.apply_gravity(delta)

	if _timer >= TOTAL_DURATION:
		sm.transition_to("EnemyChaseState", {"attack_cooldown": ATTACK_COOLDOWN})
