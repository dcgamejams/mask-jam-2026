extends Node3D

@onready var main_menu: CanvasLayer = $MainMenu

@onready var startbutton: Button = %Startbutton
@onready var player_start_position: Node3D = $PlayerStartPosition
@onready var PLAYER_CHARACTER_SCENE = preload("uid://bwggrf7sbmkcv")
@onready var menu_camera_focus: Node3D = $MenuCameraFocus
@onready var camera_3d: Camera3D = $MenuCameraFocus/Camera3D

@export var camera_rotation_speed = 1.0

<<<<<<< HEAD
@onready var death_menu: CanvasLayer = $DeathMenu
@onready var restart_button: Button = $DeathMenu/Control/MarginContainer/VBoxContainer/RestartButton
@onready var time_label: Label = $DeathMenu/Control/MarginContainer/VBoxContainer/Time

var time_start = 0.0

=======
>>>>>>> 4e48514 (feat: add goat health)
func _ready() -> void:
	startbutton.pressed.connect(start_game)
	restart_button.pressed.connect(restart)
	restart_button.disabled = true
	death_menu.hide()

func _process(delta: float) -> void:
	menu_camera_focus.rotate(Vector3.UP, camera_rotation_speed * delta)
	camera_3d.look_at(menu_camera_focus.global_position)

func restart():
	get_tree().reload_current_scene()

func start_game():
	time_start = Time.get_unix_time_from_system()
	var player : PlayerCharacter = PLAYER_CHARACTER_SCENE.instantiate()
	player.position = player_start_position.position
	player.rotation = player_start_position.rotation
	add_child(player)
	player.health_system.signal_death.connect(you_died)
	main_menu.queue_free()
	Global.signal_start.emit()

func you_died():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	restart_button.disabled = false
	var timeSurvived: int = Time.get_unix_time_from_system() - time_start;
	var minuteValue = timeSurvived / 60
	var secondValue = timeSurvived % 60
	var minuteLabel = "minute" if minuteValue == 1 else "minutes"
	var secondsLabel = "second" if secondValue == 1 else "seconds"
	time_label.text = "You survived for " + str(minuteValue) + " " + minuteLabel + " and " + str(secondValue) + " " + secondsLabel + "." 
	death_menu.show()
	
