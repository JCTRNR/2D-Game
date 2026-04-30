class_name HitData
extends Resource

@export var damage: int = 1
@export var stagger_value: float = 20.0
@export var knockback: Vector2 = Vector2(360, -120)
@export var hit_pause: float = 0.04
# source is not exported — Node refs can't live in a Resource asset
var source: Node

static func make_light(p_damage: int, p_stagger: float, p_knockback: Vector2, p_source: Node) -> HitData:
	var h := HitData.new()
	h.damage        = p_damage
	h.stagger_value = p_stagger
	h.knockback     = p_knockback
	h.source        = p_source
	h.hit_pause     = 0.04
	return h

static func make_heavy(p_damage: int, p_stagger: float, p_knockback: Vector2, p_source: Node) -> HitData:
	var h := HitData.new()
	h.damage        = p_damage
	h.stagger_value = p_stagger
	h.knockback     = p_knockback
	h.source        = p_source
	h.hit_pause     = 0.07
	return h
