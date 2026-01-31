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

	# As good practice, you should replace UI actions with custom gameplay actions.

	velocity.x = Vector3.ONE.x * SPEED
	velocity.z = Vector3.ONE.z * SPEED
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
