extends Camera3D

var canShoot:bool = true

var CurrentAmmo:int = 10
var MaxAmmo:int = 10

@export var Weapon: Node3D
@export var player: PlayerCharacter
@onready var super_shotgun: WeaponModel = %SuperShotgun
@onready var camera : Camera3D = %Camera
@onready var gun_origin: Marker3D = %"Gun Origin"

var minSpread := 0.0
var maxSpread := 3.0

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#print("Left click at: ", event.position)
			
			if canShoot:
				if CurrentAmmo > 0:
					var ray_origin: Vector3 = camera.global_position
					var ray_direction: Vector3 = -player.cam_holder.global_basis.z
					fire_manual_raycast(ray_origin, ray_direction)
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

func fire_scatter_raycast():
	var ray_origin: Vector3 = camera.global_position
	var ray_direction: Vector3 = -player.cam_holder.global_basis.z
	for i in 20:
		#hitscanShot(target)
		var spread_min := 4.0
		var spread_max := 15.0
		var cast_to = Vector3(randf_range(spread_min, spread_max), randf_range(spread_min, spread_max), -20.0) * 0.01
		fire_manual_raycast(ray_origin, ray_direction + cast_to)

func fire_manual_raycast(ray_origin: Vector3, cast_to):
	@warning_ignore("narrowing_conversion")
	await get_tree().create_timer(randi_range(0.02, 0.1)).timeout
	
	#get camera positino and direction for vector
	#var ray_origin: Vector3 = camera.global_position
	#var ray_direction: Vector3 = -camera.global_basis.z
	
	# Define the ray's end point (e.g., 1000 units away)
	var ray_length: float = 50.0
	var ray_end: Vector3 = ray_origin + (cast_to * ray_length)
	
	# CRITICAL: DEBUG HERE, do not enable it gets in the way o caera
	#DebugDraw3D.draw_line(ray_origin, ray_end, Color.NAVAJO_WHITE, 0.5)

	# Perform the intersection query
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	# Optional: add exceptions, e.g., query.set_exclude([self])
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		if result.collider is Enemy:
			var enemy: Enemy = result.collider
			print("Hit: ", result.collider.name)
			enemy.health_system.damage(50, 999)
		elif result.collider is Goat:
			print("Hit: ", result.collider.name)
			var goat: Goat = result.collider
			goat.health_system.damage(500, 999)

func _on_super_shotgun_shooting_animation_finished() -> void:
	ResetShooting()

func fire_poc():
	var target = getCameraPOV()
	hitscanShot(target)

func getCameraPOV():  
	var _window : Window = get_window()
	var viewport : Vector2i
	
	# NOTE: TODO fix this AD.
	#match viewport to window size, to ensure that the raycast goes in the right direction
	#match window.content_scale_mode:
		#window.CONTENT_SCALE_MODE_VIEWPORT:
			#viewport = window.content_scale_size
		#window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
			#viewport = window.content_scale_size
		#window.CONTENT_SCALE_MODE_DISABLED:
			#viewport = window.get_size()
#
	viewport = get_viewport().get_visible_rect().size
			
	#Start raycast in camera position, and launch it in camera direction 
	@warning_ignore("integer_division")
	var raycastStart = camera.project_ray_origin(viewport/2)
	@warning_ignore("integer_division")
	var raycastEnd = raycastStart + camera.project_ray_normal(viewport/2) * 50.0 
	#if cW.type == cW.types.PROJECTILE: raycastEnd = raycastStart + camera.project_ray_normal(viewport/2) * 280
	
	#Create intersection space to contain possible collisions 
	var newIntersection = PhysicsRayQueryParameters3D.create(raycastStart, raycastEnd)
	var intersection = get_world_3d().direct_space_state.intersect_ray(newIntersection)
	
	#If the raycast has collide with something, return collision point transform properties
	if !intersection.is_empty():
		var collisionPoint = intersection.position
		return collisionPoint 
	#Else, return the end of the raycast (so nothing, because he hasn't collide with anything) 
	else:
		return raycastEnd 


func hitscanShot(pointOfCollisionHitscan : Vector3):
	var attackPoint = gun_origin
	#set up weapon shot sprad 
	var spread = Vector3(randf_range(minSpread, maxSpread), randf_range(minSpread, maxSpread), randf_range(minSpread, maxSpread))
	
	#calculate direction of the hitscan bullet 
	var hitscanBulletDirection = (pointOfCollisionHitscan - attackPoint.get_global_transform().origin).normalized()
	
	#create new intersection space to contain possibe collisions 
	var newIntersection = PhysicsRayQueryParameters3D.create(attackPoint.get_global_transform().origin, pointOfCollisionHitscan + spread)

	DebugDraw3D.draw_line(attackPoint.get_global_transform().origin, pointOfCollisionHitscan + spread, Color.NAVAJO_WHITE, 0.5)

	newIntersection.set_exclude([player.get_rid()])
	newIntersection.collide_with_areas = true
	newIntersection.collide_with_bodies = true 
	var hitscanBulletCollision = get_world_3d().direct_space_state.intersect_ray(newIntersection)

	#if the raycast has collide
	if hitscanBulletCollision: 
		if hitscanBulletCollision.collider is Enemy:
			var enemy: Enemy = hitscanBulletCollision.collider
			print("Hit: ", hitscanBulletCollision.collider.name)
			enemy.health_system.damage(50, 999)
		elif hitscanBulletCollision.collider is Goat:
			print("Hit: ", hitscanBulletCollision.collider.name)
			var goat: Goat = hitscanBulletCollision.collider
			goat.health_system.damage(500, 999)
