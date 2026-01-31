extends Node3D

class_name WeaponModel

@onready var animation_player = $AnimationPlayer

@onready var parent_node = get_parent()

signal ShootingAnimationFinished

func _ready() -> void:
	pass
	

func _playShootingAnimtion() -> void:
	animation_player.play("ShootAndReload")

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_playShootingAnimtion()
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	ShootingAnimationFinished.emit()
	
