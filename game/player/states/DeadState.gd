class_name DeadState
extends PlayerState

var _timer: float = 0.0
const RESPAWN_DELAY := 1.5

func enter(_params: Dictionary = {}) -> void:
	_timer = 0.0
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.hurtbox.monitorable = false

func update(delta: float) -> void:
	_timer += delta
	if _timer >= RESPAWN_DELAY:
		SaveManager.load_checkpoint()
