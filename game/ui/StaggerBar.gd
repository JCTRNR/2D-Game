class_name StaggerBar
extends ProgressBar

# Floats above an enemy, shows stagger fill, auto-hides when inactive.

const FADE_DELAY := 1.5

var _fade_timer: float = 0.0
var _visible_flag: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(60.0, 6.0)
	modulate.a = 0.0
	show_percentage = false

func update_stagger(current: float, maximum: float) -> void:
	max_value = maximum
	value     = current
	if current > 0.0:
		modulate.a  = 1.0
		_fade_timer = FADE_DELAY
		_visible_flag = true

func _process(delta: float) -> void:
	if not _visible_flag:
		return
	_fade_timer -= delta
	if _fade_timer <= 0.0:
		_visible_flag = false
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
