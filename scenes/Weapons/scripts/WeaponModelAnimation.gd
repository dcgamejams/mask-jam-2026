extends Node3D

class_name WeaponModel

@onready var animation_player = $AnimationPlayer

@onready var particle_animation_player = $Root/Skeleton3D/Barrel/Barrels/MuzzleFlash_01/AnimationPlayer
@onready var marker_3d: Marker3D = %Marker3D

@onready var parent_node = get_parent()

signal ShootingAnimationFinished

func _ready() -> void:
	Global.Shoot.connect(ShootSignal)
	particle_animation_player.play("RESET")
	

func _playShootingAnimtion() -> void:
	animation_player.play("ShootAndReload")
	particle_animation_player.play("main")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	ShootingAnimationFinished.emit()
	
	
func ShootSignal() -> void:
	_playShootingAnimtion()
	
