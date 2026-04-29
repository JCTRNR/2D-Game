class_name PlayerInputHandler
extends Node

# Continuous state (poll every frame)
var move_direction: float = 0.0
var jump_held:      bool  = false
var look_up:        bool  = false
var look_down:      bool  = false
var fast_fall:      bool  = false
var jump_released:  bool  = false

# One-shot events — accumulated in _process, flushed by PlayerStateMachine
# after each physics_update so they are never missed due to process/physics desync.
var jump_pressed:  bool = false
var attack_light:  bool = false
var attack_heavy:  bool = false
var dodge:         bool = false
var interact:      bool = false

func _process(_delta: float) -> void:
	move_direction = Input.get_axis("move_left", "move_right")
	jump_held      = Input.is_action_pressed("jump")
	look_up        = Input.is_action_pressed("look_up")
	look_down      = Input.is_action_pressed("look_down")
	fast_fall      = look_down
	jump_released  = Input.is_action_just_released("jump")

	# OR-accumulate — stay true until flush() is called
	if Input.is_action_just_pressed("jump"):         jump_pressed  = true
	if Input.is_action_just_pressed("attack_light"): attack_light  = true
	if Input.is_action_just_pressed("attack_heavy"): attack_heavy  = true
	if Input.is_action_just_pressed("dodge"):        dodge         = true
	if Input.is_action_just_pressed("interact"):     interact      = true

func flush() -> void:
	jump_pressed  = false
	attack_light  = false
	attack_heavy  = false
	dodge         = false
	interact      = false
	jump_released = false
