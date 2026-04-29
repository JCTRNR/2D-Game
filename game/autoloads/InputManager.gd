extends Node

func _ready() -> void:
	_register_actions({
		"move_left":    [KEY_A, KEY_LEFT],
		"move_right":   [KEY_D, KEY_RIGHT],
		"jump":         [KEY_SPACE],
		"attack_light": [KEY_Z],
		"attack_heavy": [KEY_X],
		"dodge":        [KEY_SHIFT],
		"interact":     [KEY_E],
		"look_up":      [KEY_W, KEY_UP],
		"look_down":    [KEY_S, KEY_DOWN],
	})

func _register_actions(actions: Dictionary) -> void:
	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		else:
			InputMap.action_erase_events(action_name)
		for keycode in actions[action_name]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)
