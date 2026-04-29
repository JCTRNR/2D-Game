class_name TestEnemy
extends EnemyBase

func _ready() -> void:
	# Tune values for a basic prototype enemy
	base_health     = 3
	base_stagger    = 80.0
	has_shield      = false
	detection_range = 450.0

	# Call parent _ready AFTER setting values above
	super._ready()

	add_to_group("enemies")
