class_name Player
extends CharacterBody2D

# ── Physics constants (HK-tuned for 1920×1080) ──────────────────────────────
const SPEED             := 280.0
const ACCELERATION      := 1800.0
const DECELERATION      := 2200.0
const AIR_ACCELERATION  := 1400.0
const AIR_DECELERATION  := 800.0

const JUMP_VELOCITY           := -950.0
const JUMP_GRAVITY            := 1800.0
const FALL_GRAVITY            := 3500.0
const FAST_FALL_GRAVITY       := 5500.0
const MAX_FALL_SPEED          := 1400.0
const JUMP_RELEASE_MULTIPLIER := 0.5

const COYOTE_TIME      := 0.12
const JUMP_BUFFER_TIME := 0.12

# ── State ─────────────────────────────────────────────────────────────────────
var facing: float = 1.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# ── Component references ──────────────────────────────────────────────────────
var input: PlayerInputHandler
var state_machine: PlayerStateMachine
var health: HealthComponent
var stagger: StaggerComponent
var hurtbox: Hurtbox
var light_hitbox: Hitbox
var heavy_hitbox: Hitbox

var _visual: Polygon2D
var _hitbox_pivot: Node2D   # flips with facing, hitboxes are children of this

func _ready() -> void:
	add_to_group("player")
	_build_collision()
	_build_visual()
	_build_components()
	_build_hitboxes()
	_build_state_machine()
	RoomManager.register_player(self)

func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	move_and_slide()

# ── Movement helpers (called by states) ───────────────────────────────────────
func apply_horizontal_movement(delta: float, accel: float, decel: float) -> void:
	var dir := input.move_direction
	if not is_zero_approx(dir):
		velocity.x = move_toward(velocity.x, dir * SPEED, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

func apply_gravity(delta: float, gravity: float) -> void:
	velocity.y = min(velocity.y + gravity * delta, MAX_FALL_SPEED)

func update_facing(direction: float) -> void:
	if not is_zero_approx(direction):
		facing = sign(direction)
		_visual.scale.x = facing
		_hitbox_pivot.scale.x = facing

# ── Timer ticks ───────────────────────────────────────────────────────────────
func _tick_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(0.0, coyote_timer - delta)

	if input.jump_pressed:
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

# ── Hit reception ─────────────────────────────────────────────────────────────
func _on_hurtbox_received_hit(hit_data: HitData) -> void:
	if state_machine.current_state is DeadState:
		return
	health.take_damage(hit_data.damage)
	if health.is_dead():
		state_machine.transition_to("DeadState")
	else:
		state_machine.transition_to("HurtState", {"knockback": hit_data.knockback})

func _on_hit_landed(target_hurtbox: Hurtbox, hit_data: HitData) -> void:
	target_hurtbox.apply_hit(hit_data)

# ── Node construction ─────────────────────────────────────────────────────────
func _build_collision() -> void:
	collision_layer = 1    # layer 1: player body
	collision_mask  = 4    # collides with layer 3: world

	var col   := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28.0, 50.0)
	col.shape  = shape
	add_child(col)

func _build_visual() -> void:
	_visual = Polygon2D.new()
	_visual.polygon = PackedVector2Array([
		Vector2(-14.0, -25.0), Vector2(14.0, -25.0),
		Vector2( 14.0,  25.0), Vector2(-14.0, 25.0),
	])
	_visual.color = Color(0.3, 0.6, 1.0)
	add_child(_visual)

	# Small directional nose so facing is visible at a glance
	var nose := Polygon2D.new()
	nose.polygon = PackedVector2Array([
		Vector2(14.0, -7.0), Vector2(22.0, 0.0), Vector2(14.0, 7.0),
	])
	nose.color = Color(0.6, 0.85, 1.0)
	_visual.add_child(nose)

func _build_components() -> void:
	input = PlayerInputHandler.new()
	add_child(input)

	health = HealthComponent.new()
	health.max_health = 5
	add_child(health)

	stagger = StaggerComponent.new()
	add_child(stagger)

func _build_hitboxes() -> void:
	# Hurtbox ─ receives incoming hits
	hurtbox = Hurtbox.new()
	hurtbox.owner_entity  = self
	hurtbox.collision_layer = 32   # layer 6: player hurtbox
	hurtbox.collision_mask  = 0
	var hb_col  := CollisionShape2D.new()
	var hb_rect := RectangleShape2D.new()
	hb_rect.size = Vector2(28.0, 50.0)
	hb_col.shape = hb_rect
	hurtbox.add_child(hb_col)
	add_child(hurtbox)
	hurtbox.received_hit.connect(_on_hurtbox_received_hit)

	# Pivot node so hitboxes flip automatically with facing
	_hitbox_pivot = Node2D.new()
	_hitbox_pivot.name = "HitboxPivot"
	add_child(_hitbox_pivot)

	# Light attack hitbox
	light_hitbox = Hitbox.new()
	light_hitbox.owner_entity    = self
	light_hitbox.collision_layer = 8     # layer 4: player hitbox
	light_hitbox.collision_mask  = 64    # detects layer 7: enemy hurtbox
	var lh_col  := CollisionShape2D.new()
	var lh_rect := RectangleShape2D.new()
	lh_rect.size     = Vector2(50.0, 30.0)
	lh_col.position  = Vector2(39.0, 0.0)
	lh_col.shape     = lh_rect
	light_hitbox.add_child(lh_col)
	_hitbox_pivot.add_child(light_hitbox)
	light_hitbox.hit_landed.connect(_on_hit_landed)

	# Heavy attack hitbox
	heavy_hitbox = Hitbox.new()
	heavy_hitbox.owner_entity    = self
	heavy_hitbox.collision_layer = 8
	heavy_hitbox.collision_mask  = 64
	var hh_col  := CollisionShape2D.new()
	var hh_rect := RectangleShape2D.new()
	hh_rect.size     = Vector2(70.0, 40.0)
	hh_col.position  = Vector2(49.0, 0.0)
	hh_col.shape     = hh_rect
	heavy_hitbox.add_child(hh_col)
	_hitbox_pivot.add_child(heavy_hitbox)
	heavy_hitbox.hit_landed.connect(_on_hit_landed)

func _build_state_machine() -> void:
	state_machine = PlayerStateMachine.new()
	state_machine.name = "StateMachine"
	add_child(state_machine)

	var states_to_add: Array = [
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
	for entry in states_to_add:
		var s: PlayerState = entry[1]
		s.name = entry[0]
		state_machine.add_child(s)

	# Deferred so state_machine._ready() can finish populating its states dict first
	state_machine.call_deferred("start", "IdleState")
