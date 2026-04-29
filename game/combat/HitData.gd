class_name HitData
extends RefCounted

enum DamageType { LIGHT, HEAVY }

var damage: int = 0
var damage_type: DamageType = DamageType.LIGHT
var stagger_value: float = 0.0
var knockback: Vector2 = Vector2.ZERO
var source: Node = null

# Timing window stub for future Arkham-style system.
# 'true' means this hit landed within the perfect-timing window.
var perfect_timing: bool = false

static func make_light(dmg: int, stagger: float, kb: Vector2, src: Node) -> HitData:
	var h := HitData.new()
	h.damage = dmg
	h.damage_type = DamageType.LIGHT
	h.stagger_value = stagger
	h.knockback = kb
	h.source = src
	return h

static func make_heavy(dmg: int, stagger: float, kb: Vector2, src: Node) -> HitData:
	var h := HitData.new()
	h.damage = dmg
	h.damage_type = DamageType.HEAVY
	h.stagger_value = stagger
	h.knockback = kb
	h.source = src
	return h
