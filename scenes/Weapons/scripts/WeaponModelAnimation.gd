extends Node3D

class_name WeaponModel

@onready var animation_player = $AnimationPlayer

@onready var parent_node = get_parent()

signal ShootingAnimationFinished

func _ready() -> void:
	Global.Shoot.connect(ShootSignal)
	

func _playShootingAnimtion() -> void:
	animation_player.play("ShootAndReload")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	ShootingAnimationFinished.emit()
	
	
func ShootSignal() -> void:
	_playShootingAnimtion()
	
