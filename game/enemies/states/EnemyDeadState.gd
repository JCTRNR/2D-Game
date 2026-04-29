class_name EnemyDeadState
extends EnemyState

func enter(_params: Dictionary = {}) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.set_physics_process(false)
	enemy.hurtbox.monitorable = false
	enemy.hitbox.deactivate()
	# Fade out and remove after a short delay
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "modulate:a", 0.0, 0.6)
	tween.tween_callback(enemy.queue_free)
