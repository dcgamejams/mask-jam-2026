extends Node3D

@onready var main_menu: CanvasLayer = $MainMenu

@onready var startbutton: Button = %Startbutton
@onready var player_start_position: Node3D = $PlayerStartPosition
@onready var PLAYER_CHARACTER_SCENE = preload("uid://bwggrf7sbmkcv")
@onready var menu_camera_focus: Node3D = $MenuCameraFocus
@onready var camera_3d: Camera3D = $MenuCameraFocus/Camera3D

@export var camera_rotation_speed = 1.0

@onready var death_menu: CanvasLayer = $DeathMenu
@onready var restart_button: Button = $DeathMenu/Control/MarginContainer/VBoxContainer/RestartButton
@onready var time_label: Label = $DeathMenu/Control/MarginContainer/VBoxContainer/Time
@onready var death_title: Label = $DeathMenu/Control/MarginContainer/VBoxContainer/Title

@onready var introduction: CanvasLayer = $Introduction
@onready var startbutton_intro: Button = $Introduction/Control/MarginContainer/VBoxContainer/Startbutton
@onready var intro_camera_position: Node3D = $MenuCameraFocus/IntroCameraPosition

@export var cameraTweenTime = 1.0
var cameraTween : Tween

var time_start = 0.0
var player : PlayerCharacter

func _ready() -> void:

	


	startbutton.pressed.connect(load_intro)
	restart_button.pressed.connect(restart)
	restart_button.disabled = true
	startbutton_intro.pressed.connect(start_game)
	startbutton_intro.disabled = true
	introduction.hide()
	death_menu.hide()

func _process(delta: float) -> void:
	menu_camera_focus.rotate(Vector3.UP, camera_rotation_speed * delta)
	camera_3d.look_at(menu_camera_focus.global_position)
	intro_camera_position.look_at(menu_camera_focus.global_position)

func restart():
	get_tree().reload_current_scene()
	
func load_intro():
	main_menu.queue_free()
	startbutton_intro.disabled = false;
	introduction.show()
	var originalCameraSpeed = camera_rotation_speed
	camera_rotation_speed = 0
	if cameraTween:
		cameraTween.kill()
	cameraTween = create_tween()
	cameraTween.tween_property(camera_3d,"transform", intro_camera_position.transform, cameraTweenTime).set_ease(Tween.EASE_IN_OUT)
	cameraTween.tween_callback(
		func():
			camera_rotation_speed = originalCameraSpeed
	)

func start_game():
	introduction.queue_free()
	time_start = Time.get_unix_time_from_system()
	player = PLAYER_CHARACTER_SCENE.instantiate()
	player.position = player_start_position.position
	player.rotation = player_start_position.rotation
	add_child(player)
	player.health_system.signal_death.connect(you_died)
	var goat : Goat = get_tree().get_first_node_in_group('Goat')
	goat.health_system.signal_death.connect(goat_died)
	
	Global.signal_start.emit()

func goat_died():
	death_title.text = "Your GOAT died!"
	if player:
		player.health_system.damage(9999, 1)

func you_died():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	restart_button.disabled = false
	var timeSurvived: int = Time.get_unix_time_from_system() - time_start;
	@warning_ignore("integer_division")
	var minuteValue = timeSurvived / 60
	var secondValue = timeSurvived % 60
	var minuteLabel = "minute" if minuteValue == 1 else "minutes"
	var secondsLabel = "second" if secondValue == 1 else "seconds"
	time_label.text = "You survived for " + str(minuteValue) + " " + minuteLabel + " and " + str(secondValue) + " " + secondsLabel + "." 
	death_menu.show()
