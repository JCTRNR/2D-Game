class_name PlayerSprite
extends AnimatedSprite2D

const W := 44
const H := 84

# Maps both old monolithic state names and new state-machine node names → animation
const ANIM_MAP := {
	"Idle": "idle",         "IdleState": "idle",
	"Run": "run",           "MoveState": "run",
	"Jump": "jump",         "JumpState": "jump",
	"Fall": "fall",         "FallState": "fall",
	"AttackLight": "attack_light", "AttackLightState": "attack_light",
	"AttackHeavy": "attack_heavy", "AttackHeavyState": "attack_heavy",
	"Dodge": "dodge",       "DodgeState": "dodge",
	"Hurt": "hurt",         "HurtState": "hurt",
	"Dead": "dead",         "DeadState": "dead",
}

# [base_color, fps, frame_count, loop]
const ANIMS := {
	"idle":         [Color(0.20, 0.45, 1.00), 4,  4, true ],
	"run":          [Color(0.15, 0.80, 1.00), 8,  6, true ],
	"jump":         [Color(0.55, 0.90, 1.00), 8,  3, false],
	"fall":         [Color(0.10, 0.20, 0.85), 6,  3, true ],
	"attack_light": [Color(1.00, 0.90, 0.10), 16, 4, false],
	"attack_heavy": [Color(1.00, 0.50, 0.05), 12, 6, false],
	"dodge":        [Color(0.70, 0.25, 1.00), 14, 4, false],
	"hurt":         [Color(1.00, 0.35, 0.35), 10, 3, false],
	"dead":         [Color(0.40, 0.40, 0.45),  6, 5, false],
}

func _ready() -> void:
	sprite_frames = _build_frames()
	# Shift sprite up so its bottom edge sits at the node origin (ground level)
	offset = Vector2(0.0, -H / 2.0)
	play("idle")
	_connect_to_parent.call_deferred()

func _process(_delta: float) -> void:
	var p := get_parent()
	if "facing" in p:
		flip_h = (p.facing as float) < 0.0

func flash_hurt() -> void:
	modulate = Color(3.0, 0.6, 0.6)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.14)

func _connect_to_parent() -> void:
	var p := get_parent()
	# Monolithic Player emits state_changed directly
	if p.has_signal("state_changed"):
		if not p.state_changed.is_connected(_on_state_changed):
			p.state_changed.connect(_on_state_changed)
	# State-machine Player emits through its StateMachine child
	var sm := p.get_node_or_null("StateMachine")
	if sm and sm.has_signal("state_changed"):
		if not sm.state_changed.is_connected(_on_state_changed):
			sm.state_changed.connect(_on_state_changed)

func _on_state_changed(state: String) -> void:
	var anim: String = ANIM_MAP.get(state, "idle")
	if animation != anim:
		play(anim)

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

	# Pulse brightness across frames so each frame looks distinct
	var t := float(idx) / max(total - 1, 1)
	var brightness := 0.82 + 0.18 * sin(t * PI)
	var fill := Color(base.r * brightness, base.g * brightness, base.b * brightness, 1.0)
	img.fill(fill)

	# Darker border
	var edge := Color(fill.r * 0.5, fill.g * 0.5, fill.b * 0.5, 1.0)
	for x: int in W:
		img.set_pixel(x, 0, edge)
		img.set_pixel(x, H - 1, edge)
	for y: int in H:
		img.set_pixel(0, y, edge)
		img.set_pixel(W - 1, y, edge)

	# White eye on the right side — indicates "facing right" direction
	for dx: int in 4:
		for dy: int in 4:
			img.set_pixel(W - 9 + dx, H / 5 + dy, Color.WHITE)

	return ImageTexture.create_from_image(img)
