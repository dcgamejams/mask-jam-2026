extends CharacterBody3D

class_name Goat

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const FRICTION = 12
const ROTATION_SPEED = 2.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_system: HealthSystem = $Health
@onready var nav: NavigationSystem = $NavigationSystem
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready var soundplayer: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var IdleSounds: Array[AudioStream]

@export var PainSound: AudioStream

var gameHasStarted = false

func _ready():
	add_to_group('Goat')
	Global.signal_start.connect(start_goat)
	#nav_agent.target_desired_distance = randf_range(4.5, 6.5)
	nav_agent.avoidance_enabled = true

	nav_agent.navigation_finished.connect(func(): animation_player.play("idle"))
	nav_agent.path_changed.connect(func(): animation_player.play('walk'))
	animation_player.play("idle")
	animation_player.speed_scale = 0.7

	health_system.signal_death.connect(goat_die)
	health_system.signal_hurt.connect(_on_play_hurt_sound)
	
	_playRandomIdleSound()
	
	
func _playRandomIdleSound() -> void:
	
	await get_tree().create_timer(randf_range(5.0, 15.0)).timeout
	soundplayer.stream = IdleSounds.pick_random()
	
	soundplayer.play()
	
	_playRandomIdleSound()
	
	
	
func _physics_process(delta: float) -> void:
	velocity.y -= gravity * delta

	move_and_look(delta)
	move_and_slide()
	
func goat_die():
	queue_free()

var target

func start_goat():
	gameHasStarted = true
	nav.pick_patrol_destination()

func move_and_look(delta):
	if not gameHasStarted:
		return
	var new_look_at
	if nav_agent.is_navigation_finished() == false:
		velocity = (nav.next_path_pos - global_transform.origin).normalized() * 1.0
	else:
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
		velocity.y -= gravity * delta

	new_look_at = nav.next_path_pos

	# Finally fix "Target and up vectors are colinear" by
	# doing the same checks as the source code (used C++ source!)
	# https://github.com/godotengine/godot/issues/79146
	var v_z : Vector3 = (new_look_at - position).normalized()
	# Perpendicular vector using up+front.
	var v_x : Vector3 = Vector3.UP.cross(-v_z)	
	if v_x.is_zero_approx():
		return
	
	look_at(new_look_at)

func _on_play_hurt_sound() -> void:
	if randi_range(0, 1) == 0:
		soundplayer.stream = PainSound
		soundplayer.play()
