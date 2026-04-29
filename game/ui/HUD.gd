class_name HUD
extends CanvasLayer

var health_display: HealthDisplay

func _ready() -> void:
	_build_ui()
	_connect_player.call_deferred()

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	add_child(margin)

	health_display = HealthDisplay.new()
	margin.add_child(health_display)

func _connect_player() -> void:
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.health == null:
		return
	health_display.setup(player.health.max_health)
	player.health.health_changed.connect(health_display.update_health)
