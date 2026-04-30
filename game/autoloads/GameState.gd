extends Node

# --- Player count (multiplayer-aware from day one) ---
var player_count: int = 1

# --- Difficulty scaling hooks ---
# All enemy health/stagger scaling should multiply by these values.
func enemy_health_multiplier() -> float:
	return 1.0 + (player_count - 1) * 0.5

func enemy_count_multiplier() -> float:
	return 1.0 + (player_count - 1) * 0.5

func boss_health_multiplier() -> float:
	return 1.0 + (player_count - 1) * 0.75

# --- Ability unlock flags ---
# Add new abilities here as the game grows.
var unlocks: Dictionary = {
	"dodge":       true,   # available from the start
	"double_jump": false,
	"wall_jump":   false,
	"wall_slide":  false,
	"dash":        false,
}

func is_unlocked(ability: String) -> bool:
	return unlocks.get(ability, false)

func unlock(ability: String) -> void:
	if ability in unlocks:
		unlocks[ability] = true

# --- Last checkpoint ---
var last_checkpoint_room: String = "res://world/rooms/Room1.tscn"
var last_checkpoint_position: Vector2 = Vector2(200, 900)
