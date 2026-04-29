class_name ShieldComponent
extends Node

@export var max_shield_hp: int = 3

var current_shield_hp: int
var active: bool = true

signal shield_hit(remaining: int)
signal shield_broken

func _ready() -> void:
	current_shield_hp = max_shield_hp

# Returns true if the shield absorbed the hit (health should NOT be damaged).
# Returns false if the shield is down (hit passes through).
func try_absorb(hit_data: HitData) -> bool:
	if not active:
		return false

	if hit_data.damage_type == HitData.DamageType.HEAVY:
		current_shield_hp -= 1
		shield_hit.emit(current_shield_hp)
		if current_shield_hp <= 0:
			active = false
			shield_broken.emit()
	# Light attacks bounce off the shield — no shield damage, no health damage.
	return true
