extends Node3D

@onready var main_menu: CanvasLayer = $MainMenu

@onready var startbutton: Button = %Startbutton
@onready var player_start_position: Node3D = $PlayerStartPosition
@onready var PLAYER_CHARACTER_SCENE = preload("uid://bwggrf7sbmkcv")
@onready var menu_camera_focus: Node3D = $MenuCameraFocus
@onready var camera_3d: Camera3D = $MenuCameraFocus/Camera3D

@export var camera_rotation_speed = 1.0


func _ready() -> void:
	startbutton.pressed.connect(start_game)
	
func _process(delta: float) -> void:
	menu_camera_focus.rotate(Vector3.UP, camera_rotation_speed * delta)
	camera_3d.look_at(menu_camera_focus.global_position)

func start_game():
	var player = PLAYER_CHARACTER_SCENE.instantiate()
	player.position = player_start_position.position
	player.rotation = player_start_position.rotation
	add_child(player)
	main_menu.queue_free()
	# TODO: start spawning logic
