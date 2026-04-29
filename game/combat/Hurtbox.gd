class_name Hurtbox
extends Area2D

# Attach to a player or enemy body.
# Receives hits from Hitbox nodes.

@export var owner_entity: Node = null

signal received_hit(hit_data: HitData)

func _ready() -> void:
	# Layer 6 (player hurtbox) or layer 7 (enemy hurtbox) set on the scene node.
	monitoring = false
	monitorable = true

func apply_hit(hit_data: HitData) -> void:
	received_hit.emit(hit_data)
