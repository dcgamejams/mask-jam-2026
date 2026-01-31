extends Node3D

@onready var animation_player = $AnimationPlayer




func _ready() -> void:
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click at: ", event.position)
			animation_player.play("ShootAndReload")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right click at: ", event.position)
