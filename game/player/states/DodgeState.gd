class_name DodgeState
extends PlayerState

const DURATION     := 0.40
const DODGE_SPEED  := 500.0
const IFRAME_START := 0.05
const IFRAME_END   := 0.35

var _timer: float = 0.0
var _direction: float = 1.0

func enter(_params: Dictionary = {}) -> void:
	_timer = 0.0
	_direction = player.facing
	if not is_zero_approx(player.input.move_direction):
		_direction = sign(player.input.move_direction)

func exit() -> void:
	player.hurtbox.monitorable = true

func physics_update(delta: float) -> void:
	_timer += delta

	# I-frames active during the soul of the roll
	player.hurtbox.monitorable = not (_timer >= IFRAME_START and _timer < IFRAME_END)

	var progress := _timer / DURATION
	var speed    := DODGE_SPEED * (1.0 - smoothstep(0.6, 1.0, progress))
	player.velocity.x = _direction * speed

	if player.is_on_floor():
		player.velocity.y = 0.0
	else:
		player.apply_gravity(delta, player.FALL_GRAVITY)

	if _timer >= DURATION:
		sm.transition_to("IdleState" if player.is_on_floor() else "FallState")
