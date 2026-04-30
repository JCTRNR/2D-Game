extends CharacterBody2D

signal health_changed(current: int, max_value: int)
signal died

const LAYER_ENEMY := 2
const LAYER_WORLD := 4
const LAYER_ENEMY_HURTBOX := 64

@export var max_health: int = 8
@export var gravity: float = 2200.0
@export var friction: float = 1600.0

var current_health: int
var is_dead: bool = false
var hurt_flash_timer: float = 0.0

var _body_visual: Polygon2D
var _health_label: Label
var _hurtbox: Area2D

func _ready() -> void:
	add_to_group("enemy")

	current_health = max_health

	collision_layer = LAYER_ENEMY
	collision_mask = LAYER_WORLD

	_build_body()
	_build_hurtbox()
	_update_health_label()

	health_changed.emit(current_health, max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()

	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		_body_visual.color = Color(1.0, 1.0, 1.0, 1.0)
	else:
		_body_visual.color = Color(1.0, 0.25, 0.2, 1.0) if not is_dead else Color(0.2, 0.2, 0.2, 1.0)

func take_hit(hit_data) -> void:
	if is_dead:
		return

	var damage := 1
	var knockback := Vector2(360.0, -140.0)

	if typeof(hit_data) == TYPE_DICTIONARY:
		damage = int(hit_data.get("damage", damage))
		knockback = hit_data.get("knockback", knockback)

	current_health = max(current_health - damage, 0)
	velocity = knockback
	hurt_flash_timer = 0.08

	health_changed.emit(current_health, max_health)
	_update_health_label()

	if current_health <= 0:
		_die()

func _die() -> void:
	is_dead = true
	_hurtbox.monitorable = false
	_hurtbox.monitoring = false
	velocity = Vector2.ZERO
	died.emit()

func _build_body() -> void:
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"

	var shape := RectangleShape2D.new()
	shape.size = Vector2(48, 82)
	collision.shape = shape
	collision.position = Vector2(0, -41)
	add_child(collision)

	_body_visual = Polygon2D.new()
	_body_visual.name = "BodyVisual"
	_body_visual.polygon = PackedVector2Array([
		Vector2(-24, 0),
		Vector2(24, 0),
		Vector2(24, -82),
		Vector2(-24, -82)
	])
	_body_visual.color = Color(1.0, 0.25, 0.2, 1.0)
	add_child(_body_visual)

	_health_label = Label.new()
	_health_label.name = "HealthLabel"
	_health_label.position = Vector2(-32, -120)
	_health_label.text = ""
	add_child(_health_label)

func _build_hurtbox() -> void:
	_hurtbox = Area2D.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.collision_layer = LAYER_ENEMY_HURTBOX
	_hurtbox.collision_mask = 0
	_hurtbox.monitorable = true
	_hurtbox.monitoring = true
	add_child(_hurtbox)

	var hurt_shape := CollisionShape2D.new()
	hurt_shape.name = "CollisionShape2D"

	var rect := RectangleShape2D.new()
	rect.size = Vector2(56, 92)

	hurt_shape.shape = rect
	hurt_shape.position = Vector2(0, -46)
	_hurtbox.add_child(hurt_shape)

func _update_health_label() -> void:
	if _health_label == null:
		return

	_health_label.text = "%s/%s" % [current_health, max_health]