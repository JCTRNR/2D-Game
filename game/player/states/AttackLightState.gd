class_name AttackLightState
extends PlayerState

const TOTAL_DURATION := 0.30
const ACTIVE_START   := 0.05
const ACTIVE_END     := 0.20

var _timer: float = 0.0
var _was_on_floor: bool = false

func enter(_params: Dictionary = {}) -> void:
	_timer = 0.0
	_was_on_floor = player.is_on_floor()

func exit() -> void:
	player.light_hitbox.deactivate()

func physics_update(delta: float) -> void:
	_timer += delta

	# Activate hitbox window
	if _timer >= ACTIVE_START and _timer < ACTIVE_END:
		if not player.light_hitbox.monitoring:
			var hit := HitData.make_light(1, 40.0, Vector2(300.0 * player.facing, -100.0), player)
			player.light_hitbox.activate(hit)
	elif _timer >= ACTIVE_END:
		player.light_hitbox.deactivate()

	# Keep momentum slightly if airborne
	if not _was_on_floor:
		player.apply_gravity(delta, player.FALL_GRAVITY)

	if _timer >= TOTAL_DURATION:
		sm.transition_to("IdleState" if player.is_on_floor() else "FallState")
