extends CanvasLayer

@onready var loading: TextureRect = %Loading

const ENEMY_GHOST_1 = preload("res://scenes/enemies/ghost_1/enemy_ghost_1.tscn")
const SUPER_SHOTGUN = preload("res://scenes/Weapons/super_shotgun.tscn")

func _ready():
	spin()

	var bus_master = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_master, linear_to_db(0.0))

	var preload_shotgun: WeaponModel = SUPER_SHOTGUN.instantiate()
	preload_shotgun.position = Vector3(-5.0, 10.0, -5.0)
	add_child(preload_shotgun, true)
	preload_shotgun.ShootSignal()

	var preload_ghost = ENEMY_GHOST_1.instantiate()
	preload_ghost.position = Vector3(5.0, 20.0, 5.0)
	add_child(preload_ghost, true)

	await get_tree().create_timer(3.0).timeout
	AudioServer.set_bus_volume_db(bus_master, linear_to_db(0.8))
	queue_free()


func spin():
	var tween = create_tween().set_loops()
	tween.tween_property(loading, "rotation", TAU, 1.0).from(0.0)
	
