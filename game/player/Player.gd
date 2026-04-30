class_name Player
extends CharacterBody2D

signal health_changed(current: int, max_value: int)

# ── Physics constants ──────────────────────────────────────────────────────────
const MAX_SPEED               := 360.0
const ACCELERATION            := 2600.0
const DECELERATION            := 3200.0
const AIR_ACCELERATION        := 1600.0
const AIR_DECELERATION        := 960.0
const JUMP_VELOCITY           := -720.0
const JUMP_RELEASE_MULTIPLIER := 0.45
const JUMP_GRAVITY            := 1800.0
const FALL_GRAVITY            := 2350.0
const FAST_FALL_GRAVITY       := 3400.0
const MAX_FALL_SPEED          := 1100.0
const COYOTE_TIME             := 0.12
const INVINCIBLE_TIME         := 0.70
const MAX_HEALTH              := 6

# ── Collision layers ───────────────────────────────────────────────────────────
const LAYER_PLAYER         := 1
const LAYER_WORLD          := 4
const LAYER_PLAYER_HITBOX  := 8
const LAYER_PLAYER_HURTBOX := 32
const LAYER_ENEMY_HURTBOX  := 64

# ── Public state (read/written by states and sprite) ──────────────────────────
var facing: float           = 1.0
var jump_buffer_timer: float = 0.0
var coyote_timer: float      = 0.0

# ── Components (states access these directly) ─────────────────────────────────
var input: PlayerInputHandler
var health: HealthComponent
var light_hitbox: Hitbox
var heavy_hitbox: Hitbox
var hurtbox: Hurtbox

var _sprite: PlayerSprite
var _hitbox_pivot: Node2D
var _invincible_timer: float = 0.0
var _sm: PlayerStateMachine

func _ready() -> void:
	add_to_group("player")
	collision_layer = LAYER_PLAYER
	collision_mask  = LAYER_WORLD

	_build_input()
	_build_body()
	_build_health()
	_build_hitboxes()
	_build_state_machine()

func _process(delta: float) -> void:
	if _sprite == null:
		return
	# Invincibility blink (Hollow Knight style)
	if _invincible_timer > 0.0:
		_sprite.visible = fmod(_invincible_timer, 0.12) >= 0.06
	else:
		_sprite.visible = true

func _physics_process(delta: float) -> void:
	# Refresh coyote while grounded; tick down once airborne
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	if coyote_timer > 0.0:      coyote_timer      -= delta
	if jump_buffer_timer > 0.0: jump_buffer_timer -= delta
	if _invincible_timer > 0.0: _invincible_timer -= delta

	# Buffer jump presses so landing within the window still jumps
	if input != null and input.jump_pressed:
		jump_buffer_timer = 0.12

# ── Helper methods called by states ───────────────────────────────────────────
func apply_gravity(delta: float, gravity: float) -> void:
	velocity.y = min(velocity.y + gravity * delta, MAX_FALL_SPEED)

func apply_horizontal_movement(delta: float, accel: float, decel: float) -> void:
	var dir := input.move_direction
	if not is_zero_approx(dir):
		velocity.x = move_toward(velocity.x, dir * MAX_SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

func update_facing(dir: float) -> void:
	if not is_zero_approx(dir):
		facing = sign(dir)
		if _hitbox_pivot:
			_hitbox_pivot.scale.x = facing

func get_debug_text() -> String:
	var state_name := _sm.current_state.name if _sm and _sm.current_state else "—"
	return "STATE: %s\nVEL: %s\nGROUND: %s\nHP: %s/%s" % [
		state_name,
		Vector2(round(velocity.x), round(velocity.y)),
		str(is_on_floor()),
		health.current_health,
		health.max_health,
	]

# ── Hit reception ──────────────────────────────────────────────────────────────
func take_hit(hit_data) -> void:
	if _invincible_timer > 0.0:
		return
	if _sm and _sm.current_state is DeadState:
		return

	var damage   := 1
	var knockback := Vector2(280.0, -260.0)
	var source: Node = null

	if hit_data is HitData:
		damage    = hit_data.damage
		knockback = hit_data.knockback
		source    = hit_data.source
	elif typeof(hit_data) == TYPE_DICTIONARY:
		damage    = int(hit_data.get("damage", 1))
		knockback = hit_data.get("knockback", knockback)
		source    = hit_data.get("source", null)

	# Always push away from the attacker regardless of attack direction
	if source:
		var away := sign(global_position.x - source.global_position.x)
		if is_zero_approx(away): away = 1.0
		knockback.x = abs(knockback.x) * away

	_invincible_timer = INVINCIBLE_TIME
	health.damage(damage)

	if _sprite:
		_sprite.flash_hurt()

	if health.is_dead():
		_sm.transition_to("DeadState")
	else:
		_sm.transition_to("HurtState", {"knockback": knockback})

# ── Node construction ──────────────────────────────────────────────────────────
func _build_input() -> void:
	input = PlayerInputHandler.new()
	input.name = "InputHandler"
	add_child(input)

func _build_body() -> void:
	var col   := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size   = Vector2(42, 82)
	col.shape    = shape
	col.position = Vector2(0, -41)  # origin at feet
	add_child(col)

	_sprite = PlayerSprite.new()
	_sprite.name = "Sprite"
	add_child(_sprite)

func _build_health() -> void:
	health            = HealthComponent.new()
	health.name       = "Health"
	health.max_health = MAX_HEALTH
	add_child(health)
	health.health_changed.connect(health_changed.emit)

func _build_hitboxes() -> void:
	# Pivot scales X with facing so hitboxes always extend in the right direction
	_hitbox_pivot      = Node2D.new()
	_hitbox_pivot.name = "HitboxPivot"
	add_child(_hitbox_pivot)

	light_hitbox = _make_hitbox("LightHitbox", Vector2(76, 44),  Vector2(50, -8))
	heavy_hitbox = _make_hitbox("HeavyHitbox", Vector2(104, 58), Vector2(64, -10))

	# Defensive hurtbox — enemy hitboxes scan this layer
	hurtbox                 = Hurtbox.new()
	hurtbox.name            = "Hurtbox"
	hurtbox.owner_entity    = self
	hurtbox.collision_layer = LAYER_PLAYER_HURTBOX
	hurtbox.collision_mask  = 0
	var hb_col  := CollisionShape2D.new()
	var hb_rect := RectangleShape2D.new()
	hb_rect.size    = Vector2(38, 78)
	hb_col.shape    = hb_rect
	hb_col.position = Vector2(0, -39)
	hurtbox.add_child(hb_col)
	add_child(hurtbox)
	hurtbox.received_hit.connect(take_hit)

func _make_hitbox(hb_name: String, size: Vector2, offset: Vector2) -> Hitbox:
	var hb              := Hitbox.new()
	hb.name              = hb_name
	hb.owner_entity      = self
	hb.collision_layer   = LAYER_PLAYER_HITBOX
	hb.collision_mask    = LAYER_ENEMY_HURTBOX
	var col             := CollisionShape2D.new()
	var rect            := RectangleShape2D.new()
	rect.size            = size
	col.shape            = rect
	col.position         = offset
	hb.add_child(col)
	_hitbox_pivot.add_child(hb)
	return hb

func _build_state_machine() -> void:
	_sm      = PlayerStateMachine.new()
	_sm.name = "StateMachine"
	add_child(_sm)

	var state_list: Array = [
		["IdleState",        IdleState.new()],
		["MoveState",        MoveState.new()],
		["JumpState",        JumpState.new()],
		["FallState",        FallState.new()],
		["AttackLightState", AttackLightState.new()],
		["AttackHeavyState", AttackHeavyState.new()],
		["DodgeState",       DodgeState.new()],
		["HurtState",        HurtState.new()],
		["DeadState",        DeadState.new()],
	]
	for entry: Array in state_list:
		var s: PlayerState = entry[1]
		s.name = entry[0]
		_sm.add_child(s)

	_sm.call_deferred("start", "IdleState")
