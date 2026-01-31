extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var player_shape_cast: ShapeCast3D = %ShapeCast3D

var player_check: Timer

func _ready():
	
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var map_center = position.direction_to(Vector3.ZERO)

	# As good practice, you should replace UI actions with custom gameplay actions.
	velocity.x = move_toward(map_center.x, 2.0, SPEED)
	velocity.z = move_toward(map_center.z, 2.0, SPEED)
	
	look_at(map_center)
	move_and_slide()
