class_name AttackHeavyState
extends PlayerState

const TOTAL_DURATION := 0.50
const STARTUP        := 0.15   # telegraph before hit
const ACTIVE_START   := 0.15
const ACTIVE_END     := 0.30

var _timer: float = 0.0
var _was_on_floor: bool = false

func enter(_params: Dictionary = {}) -> void:
	_timer = 0.0
	_was_on_floor = player.is_on_floor()

func exit() -> void:
	player.heavy_hitbox.deactivate()

func physics_update(delta: float) -> void:
	_timer += delta

	if _timer >= ACTIVE_START and _timer < ACTIVE_END:
		if not player.heavy_hitbox.monitoring:
			var hit := HitData.make_heavy(2, 70.0, Vector2(450.0 * player.facing, -80.0), player)
			player.heavy_hitbox.activate(hit)
	elif _timer >= ACTIVE_END:
		player.heavy_hitbox.deactivate()

	if not _was_on_floor:
		player.apply_gravity(delta, player.FALL_GRAVITY)

	if _timer >= TOTAL_DURATION:
		sm.transition_to("IdleState" if player.is_on_floor() else "FallState")
