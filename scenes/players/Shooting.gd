extends Camera3D

var canShoot:bool = true

var CurrentAmmo:int = 10
var MaxAmmo:int = 10

@export var Weapon: Node3D
@export var player: PlayerCharacter
@onready var super_shotgun: WeaponModel = %SuperShotgun
@onready var camera : Camera3D = %Camera
@onready var gun_origin: Marker3D = %"Gun Origin"


func _input(event):
	if player.immobile: 
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: 
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #set mouse mode as captured

			if canShoot:				
				#var ray_origin: Vector3 = camera.global_position
				#var ray_direction: Vector3 = -player.cam_holder.global_basis.z
				#fire_manual_raycast(ray_origin, ray_direction)
				fire_scatter_raycast()
				Global.Shoot.emit()
				canShoot = false	
				CurrentAmmo -= 1
				

		#print("Right click at: ", event.position)

func ResetShooting() -> void:
	canShoot = true

func fire_scatter_raycast():
	var ray_origin: Vector3 = camera.global_position
	# Ensure we use the forward vector of the camera/holder
	var forward: Vector3 = -player.cam_holder.global_basis.z
	var right: Vector3 = player.cam_holder.global_basis.x
	var up: Vector3 = player.cam_holder.global_basis.y
	var debug_origin = super_shotgun.marker_3d.global_position
	for i in 20:
		# 1. Use a lower spread range. 0.0 allows center shots.
		var spread_intensity := 0.15 # Adjust this to tighten/loosen the cone

		# 2. Calculate a random point inside a circle
		var angle = randf() * TAU
		var distance = randf() * spread_intensity

		# 3. Create the offset vector based on the camera's local axes
		var spread_offset = (right * cos(angle) * distance) + (up * sin(angle) * distance)
		var direction = (forward + spread_offset).normalized()

		fire_manual_raycast(ray_origin, direction, debug_origin)

func fire_manual_raycast(ray_origin: Vector3, direction: Vector3, debug_origin: Vector3):
	# Short random delay for "popcorn" effect
	await get_tree().create_timer(randf_range(0.05, 0.2)).timeout

	var ray_length: float = 50.0
	var ray_end: Vector3 = ray_origin + (direction * ray_length)
	var ray_end_short: Vector3 = ray_origin + (direction * ray_length / 2)


	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)

	# Optional: Exclude the player so you don't shoot yourself
	query.exclude = [player.get_rid()] 

	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		if result.collider is Enemy:
			var enemy: Enemy = result.collider
			enemy.health_system.damage(20, 999)
		elif result.collider is Goat:
			var goat: Goat = result.collider
			goat.health_system.damage(0, 999)

func _on_super_shotgun_shooting_animation_finished() -> void:
	ResetShooting()

func fire_poc():
	var target = getCameraPOV()
	hitscanShot(target)

var minSpread := 0.0
var maxSpread := 3.0

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
