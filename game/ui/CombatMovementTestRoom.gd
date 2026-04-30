extends Node2D

const LAYER_WORLD := 4

func _ready() -> void:
	_build_room()

func _build_room() -> void:
	_create_platform("Ground", Vector2(900, 840), Vector2(2200, 80))
	_create_platform("LeftWall", Vector2(-160, 500), Vector2(80, 760))
	_create_platform("SmallPlatform", Vector2(520, 660), Vector2(240, 36))
	_create_platform("HighPlatform", Vector2(920, 520), Vector2(260, 36))
	_create_platform("GapLanding", Vector2(1500, 720), Vector2(280, 40))
	_create_platform("FarPlatform", Vector2(1880, 610), Vector2(360, 40))

	_create_marker("START", Vector2(160, 710))
	_create_marker("JUMP TEST", Vector2(450, 610))
	_create_marker("COMBAT TEST", Vector2(735, 710))
	_create_marker("GAP TEST", Vector2(1400, 670))
	_create_marker("CAMERA TEST", Vector2(1800, 560))

func _create_platform(platform_name: String, pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = platform_name
	body.position = pos
	body.collision_layer = LAYER_WORLD
	body.collision_mask = 0
	add_child(body)

	var shape_node := CollisionShape2D.new()
	shape_node.name = "CollisionShape2D"

	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape

	body.add_child(shape_node)

	var visual := Polygon2D.new()
	visual.name = "Visual"
	visual.polygon = PackedVector2Array([
		Vector2(-size.x / 2.0, -size.y / 2.0),
		Vector2(size.x / 2.0, -size.y / 2.0),
		Vector2(size.x / 2.0, size.y / 2.0),
		Vector2(-size.x / 2.0, size.y / 2.0)
	])
	visual.color = Color(0.18, 0.18, 0.2, 1.0)
	body.add_child(visual)

func _create_marker(text: String, pos: Vector2) -> void:
	var label := Label.new()
	label.name = text.replace(" ", "_")
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", 22)
	add_child(label)