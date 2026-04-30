class_name Hurtbox
extends Area2D

signal received_hit(hit_data: HitData)

var owner_entity: Node

func apply_hit(hit_data: HitData) -> void:
	received_hit.emit(hit_data)
