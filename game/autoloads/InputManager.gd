extends Node

func _ready() -> void:
	# Keyboard-only actions — these overwrite project.godot entries for these actions.
	# attack_light / attack_heavy are intentionally omitted so project.godot's
	# mouse-button bindings remain active (left click = light, right click = heavy).
	_register_key_actions({
		"move_left":  [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump":       [KEY_SPACE],
		"dodge":      [KEY_SHIFT],
		"interact":   [KEY_E],
		"look_up":    [KEY_W, KEY_UP],
		"look_down":  [KEY_S, KEY_DOWN],
	})

func _register_key_actions(actions: Dictionary) -> void:
	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		else:
			InputMap.action_erase_events(action_name)
		for keycode: int in actions[action_name]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)
