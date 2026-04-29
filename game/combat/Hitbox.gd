class_name Hitbox
extends Area2D

# Attach to a player or enemy attack.
# Set owner_entity to the node that owns this hitbox.

@export var owner_entity: Node = null

# Emitted when this hitbox overlaps a Hurtbox.
# The HitData is constructed by whoever activates this hitbox.
signal hit_landed(hurtbox: Hurtbox, hit_data: HitData)

var _active_hit_data: HitData = null
var _hit_this_swing: Array[Node] = []

func _ready() -> void:
	# Layer 4 (player hitbox) or layer 5 (enemy hitbox) set on the scene node.
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)

func activate(hit_data: HitData) -> void:
	_active_hit_data = hit_data
	_hit_this_swing.clear()
	monitoring = true

func deactivate() -> void:
	monitoring = false
	_active_hit_data = null

func _on_area_entered(area: Area2D) -> void:
	if _active_hit_data == null:
		return
	if area is Hurtbox and area not in _hit_this_swing:
		_hit_this_swing.append(area)
		hit_landed.emit(area, _active_hit_data)
