class_name Hitbox
extends Area2D

signal hit_landed(hurtbox: Hurtbox, hit_data: HitData)

var owner_entity: Node
var one_hit_per_activation: bool = true
var _active_hit: HitData = null
var _hit_targets: Array[Node] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitoring = false

func activate(hit_data: HitData) -> void:
	_active_hit = hit_data
	_hit_targets.clear()
	monitoring = true

func deactivate() -> void:
	monitoring = false
	_active_hit = null

func _on_area_entered(area: Area2D) -> void:
	if _active_hit == null:
		return

	var target := area.get_parent()
	if target == null:
		return

	if one_hit_per_activation and target in _hit_targets:
		return
	_hit_targets.append(target)

	if area is Hurtbox:
		area.apply_hit(_active_hit)
		hit_landed.emit(area, _active_hit)
	elif target.has_method("take_hit"):
		# Backward-compat for nodes that don't use the Hurtbox class
		target.take_hit(_active_hit)

	_do_hit_pause(_active_hit.hit_pause)

func _do_hit_pause(duration: float) -> void:
	if duration <= 0.0:
		return
	var tree := get_tree()
	tree.paused = true
	await tree.create_timer(duration, true, false, true).timeout
	tree.paused = false
