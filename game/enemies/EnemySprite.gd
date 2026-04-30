class_name EnemySprite
extends AnimatedSprite2D

const W := 38
const H := 58

const ANIM_MAP := {
	"EnemyIdleState":    "idle",
	"EnemyPatrolState":  "walk",
	"EnemyChaseState":   "run",
	"EnemyAttackState":  "attack",
	"EnemyStaggerState": "stagger",
	"EnemyDeadState":    "dead",
}

# [base_color, fps, frame_count, loop]
const ANIMS := {
	"idle":    [Color(0.85, 0.20, 0.20),  4, 4, true ],
	"walk":    [Color(0.90, 0.40, 0.10),  7, 5, true ],
	"run":     [Color(1.00, 0.55, 0.10),  9, 6, true ],
	"attack":  [Color(1.00, 0.85, 0.10), 14, 5, false],
	"stagger": [Color(0.90, 0.60, 0.60),  8, 3, false],
	"dead":    [Color(0.35, 0.30, 0.30),  6, 5, false],
}

func _ready() -> void:
	sprite_frames = _build_frames()
	offset = Vector2(0.0, -H / 2.0)
	play("idle")
	_connect_to_parent.call_deferred()

func _connect_to_parent() -> void:
	var sm := get_parent().get_node_or_null("StateMachine")
	if sm and sm.has_signal("state_changed"):
		if not sm.state_changed.is_connected(_on_state_changed):
			sm.state_changed.connect(_on_state_changed)

func _on_state_changed(state: String) -> void:
	var anim: String = ANIM_MAP.get(state, "idle")
	if animation != anim:
		play(anim)

# Called by EnemyBase on stagger — brief overbright flash fading to normal
func flash_stagger() -> void:
	modulate = Color(3.0, 3.0, 3.0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.18)

func _build_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	for anim_name: String in ANIMS:
		var cfg: Array = ANIMS[anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, cfg[1])
		sf.set_animation_loop(anim_name, cfg[3])
		for i: int in cfg[2]:
			sf.add_frame(anim_name, _make_frame(cfg[0], i, cfg[2]))
	return sf

func _make_frame(base: Color, idx: int, total: int) -> ImageTexture:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)

	var t := float(idx) / max(total - 1, 1)
	var brightness := 0.82 + 0.18 * sin(t * PI)
	var fill := Color(base.r * brightness, base.g * brightness, base.b * brightness, 1.0)
	img.fill(fill)

	var edge := Color(fill.r * 0.5, fill.g * 0.5, fill.b * 0.5, 1.0)
	for x: int in W:
		img.set_pixel(x, 0, edge)
		img.set_pixel(x, H - 1, edge)
	for y: int in H:
		img.set_pixel(0, y, edge)
		img.set_pixel(W - 1, y, edge)

	# Eye on right side = facing right
	for dx: int in 3:
		for dy: int in 3:
			img.set_pixel(W - 7 + dx, H / 5 + dy, Color.WHITE)

	return ImageTexture.create_from_image(img)
