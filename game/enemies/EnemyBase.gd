class_name EnemyBase
extends CharacterBody2D

# ── Config (override in subclass or set via @export) ─────────────────────────
@export var base_health: int  = 3
@export var base_stagger: float = 80.0
@export var has_shield: bool  = false
@export var detection_range: float = 400.0

# ── State ─────────────────────────────────────────────────────────────────────
var facing: float = 1.0

# ── Component references ──────────────────────────────────────────────────────
var health: HealthComponent
var stagger: StaggerComponent
var shield: ShieldComponent
var hitbox: Hitbox
var hurtbox: Hurtbox
var state_machine: EnemyStateMachine

var _sprite: EnemySprite
var _hitbox_pivot: Node2D

const GRAVITY      := 2800.0
const MAX_FALL     := 1200.0

func _ready() -> void:
	_build_collision()
	_build_visual()
	_build_components()
	_build_hitboxes()
	_build_state_machine()

func _physics_process(delta: float) -> void:
	move_and_slide()

# ── Helpers (called by states) ────────────────────────────────────────────────
func apply_gravity(delta: float) -> void:
	velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL)

func update_facing(direction: float) -> void:
	if not is_zero_approx(direction):
		facing = sign(direction)
		_sprite.flip_h = facing < 0.0
		_hitbox_pivot.scale.x = facing

func can_see_player() -> bool:
	var player := get_player()
	if player == null:
		return false
	return global_position.distance_to(player.global_position) <= detection_range

func get_player() -> CharacterBody2D:
	return get_tree().get_first_node_in_group("player") as CharacterBody2D

# ── Hit reception ─────────────────────────────────────────────────────────────
func take_hit(hit_data) -> void:
	var hd: HitData
	if hit_data is HitData:
		hd = hit_data
	else:
		hd = HitData.new()
		if typeof(hit_data) == TYPE_DICTIONARY:
			hd.damage        = int(hit_data.get("damage", 1))
			hd.knockback     = hit_data.get("knockback", Vector2(360.0, -120.0))
			hd.stagger_value = float(hit_data.get("stagger_value", 20.0))
	_on_hurtbox_received_hit(hd)

func _on_hurtbox_received_hit(hit_data: HitData) -> void:
	if state_machine.current_state is EnemyDeadState:
		return

	# Try to absorb with shield first
	if has_shield and shield.active:
		if shield.try_absorb(hit_data):
			return

	health.damage(hit_data.damage)
	stagger.add_stagger(hit_data.stagger_value)

func _on_staggered() -> void:
	var player := get_player()
	var away_dir := 1.0
	if player:
		away_dir = sign(global_position.x - player.global_position.x)
	if not (state_machine.current_state is EnemyDeadState):
		state_machine.transition_to("EnemyStaggerState", {"knockback": Vector2(300.0 * away_dir, -100.0)})
	_sprite.flash_stagger()

func _on_hit_landed(target_hurtbox: Hurtbox, hit_data: HitData) -> void:
	target_hurtbox.apply_hit(hit_data)

func _on_died() -> void:
	state_machine.transition_to("EnemyDeadState")

# ── Node construction ─────────────────────────────────────────────────────────
func _build_collision() -> void:
	collision_layer = 2    # layer 2: enemy body
	collision_mask  = 4    # collides with layer 3: world

	var col   := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(36.0, 56.0)
	col.shape  = shape
	col.position = Vector2(0.0, -shape.size.y / 2.0)  # origin at feet, matches sprite
	add_child(col)

func _build_visual() -> void:
	_sprite = EnemySprite.new()
	_sprite.name = "Sprite"
	add_child(_sprite)

func _build_components() -> void:
	health = HealthComponent.new()
	health.max_health = int(base_health * GameState.enemy_health_multiplier())
	add_child(health)
	health.died.connect(_on_died)

	stagger = StaggerComponent.new()
	stagger.max_stagger = base_stagger
	add_child(stagger)
	stagger.staggered.connect(_on_staggered)

	if has_shield:
		shield = ShieldComponent.new()
		add_child(shield)

func _build_hitboxes() -> void:
	hurtbox = Hurtbox.new()
	hurtbox.owner_entity    = self
	hurtbox.collision_layer = 64   # layer 7: enemy hurtbox
	hurtbox.collision_mask  = 0
	var hb_col  := CollisionShape2D.new()
	var hb_rect := RectangleShape2D.new()
	hb_rect.size = Vector2(36.0, 56.0)
	hb_col.shape = hb_rect
	hb_col.position = Vector2(0.0, -hb_rect.size.y / 2.0)
	hurtbox.add_child(hb_col)
	add_child(hurtbox)
	hurtbox.received_hit.connect(_on_hurtbox_received_hit)

	_hitbox_pivot = Node2D.new()
	_hitbox_pivot.name = "HitboxPivot"
	add_child(_hitbox_pivot)

	hitbox = Hitbox.new()
	hitbox.owner_entity    = self
	hitbox.collision_layer = 16    # layer 5: enemy hitbox
	hitbox.collision_mask  = 32    # detects layer 6: player hurtbox
	var ah_col  := CollisionShape2D.new()
	var ah_rect := RectangleShape2D.new()
	ah_rect.size    = Vector2(60.0, 36.0)
	ah_col.position = Vector2(48.0, 0.0)
	ah_col.shape    = ah_rect
	hitbox.add_child(ah_col)
	_hitbox_pivot.add_child(hitbox)
	hitbox.hit_landed.connect(_on_hit_landed)

func _build_state_machine() -> void:
	state_machine = EnemyStateMachine.new()
	state_machine.name = "StateMachine"
	add_child(state_machine)

	var states_to_add: Array = [
		["EnemyIdleState",    EnemyIdleState.new()],
		["EnemyPatrolState",  EnemyPatrolState.new()],
		["EnemyChaseState",   EnemyChaseState.new()],
		["EnemyAttackState",  EnemyAttackState.new()],
		["EnemyStaggerState", EnemyStaggerState.new()],
		["EnemyDeadState",    EnemyDeadState.new()],
	]
	for entry in states_to_add:
		var s: EnemyState = entry[1]
		s.name = entry[0]
		state_machine.add_child(s)

	state_machine.call_deferred("start", "EnemyIdleState")
