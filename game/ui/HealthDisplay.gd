class_name HealthDisplay
extends HBoxContainer

# Renders hit-based health segments (HK mask style).

var _segments: Array[ColorRect] = []

const FILLED_COLOR := Color(0.9, 0.9, 0.9)
const EMPTY_COLOR  := Color(0.2, 0.2, 0.2, 0.6)
const SEG_SIZE     := Vector2(28.0, 28.0)
const SEG_GAP      := 4.0

func setup(max_health: int) -> void:
	for child in get_children():
		child.queue_free()
	_segments.clear()

	add_theme_constant_override("separation", int(SEG_GAP))

	for i in max_health:
		var seg := ColorRect.new()
		seg.custom_minimum_size = SEG_SIZE
		seg.color = FILLED_COLOR
		add_child(seg)
		_segments.append(seg)

func update_health(current: int, _maximum: int) -> void:
	for i in _segments.size():
		_segments[i].color = FILLED_COLOR if i < current else EMPTY_COLOR
