extends Camera3D

var canShoot:bool = true

var CurrentAmmo:int = 10
var MaxAmmo:int = 10

@export var Weapon: Node3D
@export var player: PlayerCharacter

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print("Left click at: ", event.position)
			
			if canShoot:
				if CurrentAmmo > 0:
					fire_manual_raycast()
					Global.Shoot.emit()
					canShoot = false	
					CurrentAmmo -= 1
				else:
					canShoot = false 
					CurrentAmmo = 10
					#await get_tree().create_timer(2.0).timeout
					canShoot = true

		#print("Right click at: ", event.position)
			

func ResetShooting() -> void:
	canShoot = true

func fire_manual_raycast():
	var viewport: Viewport = get_viewport()
	var camera: Camera3D = viewport.get_camera_3d()
	
	#get camera positino and direction for vector
	var ray_origin: Vector3 = camera.global_position
	var ray_direction: Vector3 = -camera.global_basis.z
	
	# Define the ray's end point (e.g., 1000 units away)
	var ray_length: float = 1000.0
	var ray_end: Vector3 = ray_origin + (ray_direction * ray_length)

	
	#DebugDraw3D.draw_line(ray_origin, ray_end, Color.RED, 100)

	# Perform the intersection query
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	# Optional: add exceptions, e.g., query.set_exclude([self])
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		if result.collider is Enemy:
			var enemy: Enemy = result.collider
			print("Hit: ", result.collider.name)
			enemy.health_system.damage(50)


func _on_super_shotgun_shooting_animation_finished() -> void:
	ResetShooting()
