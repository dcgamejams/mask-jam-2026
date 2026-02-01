extends CharacterBody3D

class_name Goat

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const FRICTION = 12
const ROTATION_SPEED = 2.0

@onready var health_system: HealthSystem = $Health
@onready var nav: NavigationSystem = $NavigationSystem
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	add_to_group('Goat')
	#nav_agent.target_desired_distance = randf_range(4.5, 6.5)
	nav_agent.avoidance_enabled = true

	health_system.signal_death.connect(goat_die)
	#nav_agent.path_changed.connect(on_path_changed)
	nav.pick_patrol_destination()

func _physics_process(delta: float) -> void:
	velocity.y -= gravity * delta

	move_and_look(delta)
	move_and_slide()
	
	
func goat_die():
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	queue_free()

var target

func move_and_look(delta):
	var new_look_at
	if nav_agent.is_navigation_finished() == false:
		velocity = (nav.next_path_pos - global_transform.origin).normalized() * 2.0
	else:
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
		velocity.y -= gravity * delta
	

	if target:
		new_look_at = target.transform.origin * Vector3(1.0, 0.5, 1.0) * -1.0
	else:
		new_look_at = nav.next_path_pos * Vector3(1.0, 0.5, 1.0) * -1.0

	# Finally fix "Target and up vectors are colinear" by
	# doing the same checks as the source code (used C++ source!)
	# https://github.com/godotengine/godot/issues/79146
	var v_z : Vector3 = (new_look_at - position).normalized()
	# Perpendicular vector using up+front.
	var v_x : Vector3 = Vector3.UP.cross(-v_z)	
	if v_x.is_zero_approx():
		return
	
	var old = transform.basis.orthonormalized() 
	look_at(new_look_at)
	var new = transform.basis.orthonormalized()
	if nav_agent.is_navigation_finished():
		transform.basis = Basis.IDENTITY
		transform.basis = lerp(old, Basis.IDENTITY, ROTATION_SPEED * delta).orthonormalized()
	else:
		transform.basis = lerp(old, new, ROTATION_SPEED * delta).orthonormalized()
