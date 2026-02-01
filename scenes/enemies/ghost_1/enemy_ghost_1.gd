# TODO: Beehave or some other behavioral tree when this state machine gets to be too much
# TODO: Random pauses between choosing another action? "Global cool down" like
# TODO: Assure this is completely server authoratative
# TODO: Perf test navigation agent to assure it doesn't consume to much CPU or cause FPS loss

extends CharacterBody3D

class_name Enemy

enum TYPE { 
	GHOST,
	CULTIST
}

@export var enemy_type: TYPE

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const FRICTION = 12
const ROTATION_SPEED = 3.0

@export_category("Enemy Required Nodes")
@export var animation_player: AnimationPlayer 
@export var health_system: HealthSystem
@export var nav: NavigationSystem
@export var nav_agent: NavigationAgent3D
@export var search_box: Area3D
@export var attack_box: Area3D

# TODO: Weak points and eyeline
# TODO: Give up chase 
#@export var hit_box: Area3D
#@export var eyeline: Area3D 

@export_category("Enemy Stats")
@export var max_speed = 5.0
@export var speed = max_speed
@export var attack_value: int = 30

var timer_attack_cooldown = Timer.new()

var target = null

@onready var AudioPlayerAmbient: AudioStreamPlayer3D = $AudioStreamPlayer3DAmbient

@export var AmbientSoundsArray: Array[AudioStream]

@onready var AudioPlayerAttack: AudioStreamPlayer3D = $AudioStreamPlayer3DAttack

@export var AttackSoundsArray: Array[AudioStream]

# ANIMATION LIST. These are required
enum LIST { 
	WALK,
	IDLE,
	ATTACK,
	HURT,
	DYING,
	DECAY
}

# ANIMATION LIST. These are required
const ANI = [
	&"walk2", # Walk
	&"idle", # Idle
	&"attack", # Attack
	&"hurt", # Hurt
	&"dying", # Dying
	&"RESET" # Decay
]

# This enum lists all the possible states the character can be in.
enum States { IDLE, SEARCHING, CHASING, ATTACKING, HURTING, DODGING, DYING, DECAYING }

# This variable keeps track of the character's current state.
var state: States = States.IDLE

func _ready(): 
	add_to_group("Enemies")
	
	if enemy_type == TYPE.CULTIST:
		print("IM A CULTIST")
	
	animation_player.playback_default_blend_time = 0.4

	nav_agent.target_desired_distance = randf_range(4.5, 6.5)
	nav_agent.avoidance_enabled = true

	attack_box.body_entered.connect(on_attack_box_entered)
	animation_player.animation_finished.connect(on_animation_finished)
	
	# Health
	health_system.signal_hurt.connect(on_hurt)
	health_system.signal_death.connect(on_death)
	
	# Nav
	#nav_agent.navigation_finished.connect(on_navigation_finished)
	nav_agent.path_changed.connect(on_path_changed)

	add_child(timer_attack_cooldown)
	timer_attack_cooldown.timeout.connect(attack)
	timer_attack_cooldown.wait_time = randf_range(2.0, 5.5)
	timer_attack_cooldown.one_shot = false
	timer_attack_cooldown.start()

	await get_tree().create_timer(0.2).timeout
	set_state(States.SEARCHING)
	
	#ambient sounds stuff 
	_play_new_random_ambient_sound()
	
func _play_new_random_ambient_sound() -> void:
	#await get_tree().create_timer(randf_range(0.5, 10.0)).timeout
	var RandomAmbientSound: AudioStream = AmbientSoundsArray.pick_random()
	AudioPlayerAmbient.stream = RandomAmbientSound
	AudioPlayerAmbient.play()
	
func _play_random_attack_sound() -> void:
	var RandomAttackSound: AudioStream = AttackSoundsArray.pick_random()
	AudioPlayerAttack.stream = RandomAttackSound
	AudioPlayerAttack.play()

func _physics_process(delta: float) -> void:
	match state:
		States.SEARCHING:
			move_and_look(delta)
		States.CHASING, States.HURTING:
			move_and_look(delta)
		States.ATTACKING:
			move_and_attack(delta)
		States.DYING:
			velocity = Vector3.ZERO
		States.DECAYING:
			velocity = Vector3.ZERO
	
	velocity.y -= gravity * delta

	move_and_slide()
	
# TODO: ADD LOOK
func move_and_attack(_delta):
	if position.distance_to(attack_position) > 0.5:
		velocity = (attack_position - global_transform.origin).normalized() * speed * 1.4
	elif position.distance_to(attack_position) > 8.0: 
		set_state(States.CHASING)
		nav.chase_target()
	else:
		set_state(States.CHASING)
		nav.chase_target()

func move_and_look(delta):
	var new_look_at
	if nav_agent.is_navigation_finished() == false:
		velocity = (nav.next_path_pos - global_transform.origin).normalized() * speed
	else:
		velocity = velocity.move_toward(Vector3.ZERO, FRICTION * delta)
		velocity.y -= gravity * delta

	if target:
		new_look_at = target.transform.origin
	else:
		new_look_at = nav.next_path_pos

	# Finally fix "Target and up vectors are colinear" by
	# doing the same checks as the source code (used C++ source!)
	# https://github.com/godotengine/godot/issues/79146
	var v_z : Vector3 = (new_look_at - position).normalized()
	# Perpendicular vector using up+front.
	var v_x : Vector3 = Vector3.UP.cross(-v_z)	
	if v_x.is_zero_approx():
		return
	
	var old = transform.basis.orthonormalized()
	look_at(new_look_at)
	var new = transform.basis.orthonormalized()
	transform.basis = lerp(old, new, ROTATION_SPEED * delta).orthonormalized()


func set_state(new_state: States) -> void:
	var previous_state := state
	state = new_state

	############
	# You can check both the previous and the new state to determine what to do when the state changes. 
	# This checks the previous state.

	#print("STATE", States.keys()[state])
	# Never leave Dying unless it's to decay. TODO: No decay state.
	if previous_state == States.DYING and new_state != States.DECAYING: 
		return

	# Never leave Decaying.
	if previous_state == States.DECAYING: 
		return

	if previous_state == States.ATTACKING && new_state == States.HURTING:
		animation_player.play(ANI[LIST.HURT])
		return
				

	#if previous_state == States.ATTACKING && animation_player.current_animation == ANI[LIST.ATTACK]: 
		#return
#
	#if health_system.health == 0 and state != States.DYING:
		#set_state(States.DYING)
		#return

	#############
	# Here, I check the new state.
	if state == States.SEARCHING:
		target = null
		if not animation_player.current_animation == ANI[LIST.HURT]:
			animation_player.play(ANI[LIST.WALK])
		speed = 3.0
		nav.pick_patrol_destination()
		pass

	if state == States.CHASING:
		if not animation_player.current_animation == ANI[LIST.HURT]:
			animation_player.play(ANI[LIST.WALK])
		nav.chase_target()
		speed = 5.0
		pass
		
	if state == States.ATTACKING:
		animation_player.play(ANI[LIST.ATTACK])
		attack_box.set_deferred('monitoring', true)
	#else:
		#attack_box.set_deferred('monitoring', false)
	
	if state == States.HURTING:
		if health_system.health == 0:
			return
		animation_player.play(ANI[LIST.HURT])
		# TODO: interrupt whever we are doing to get hurt. Maybe a 33% chance to? 
		var get_player = get_tree().get_first_node_in_group('PlayerCharacter')
		if get_player:
			target = get_player
			#set_state(States.CHASING)

	if state == States.DYING:
		# Helps prevent monitoring issues
		nav.timer_chase_target.stop()
		nav.timer_navigate.stop()
		nav.timer_give_up.stop()
		animation_player.play(ANI[LIST.DYING])
		set_process(false)
		await get_tree().create_timer(2.0).timeout
		queue_free()
		# Decay triggered by animation

	if state == States.DECAYING:
		animation_player.play(ANI[LIST.DECAY])
		decay()
		pass

func decay():
	await get_tree().create_timer(10.0).timeout
	set_process(false) # could queue free on animation finishedf
	await get_tree().process_frame
	queue_free()

func on_animation_finished(animation_name):
	if animation_name == ANI[LIST.HURT]:
		if target:
			set_state(States.CHASING)
			#animation_player.play(ANI[LIST.IDLE])

	if animation_name == ANI[LIST.ATTACK]:
		set_state(States.CHASING)

func on_hurt():
	set_state(States.HURTING)
	
func on_death():
	# TODO: #CRITICAL " DEATH PROPER
	set_state(States.DYING)

func can_attack() -> bool:
	if not target:
		return false
		
	if health_system.health == 0:
		return false
		
	if state in [States.ATTACKING, States.DYING, States.DECAYING]:
		return false

	return true


var attack_position

func attack():
	if can_attack() == false:
		return
	# TODO: Pick a position on the left or the right of the player.
	if state == States.CHASING or state == States.HURTING:
		await get_tree().create_timer(0.05).timeout
		if nav_agent.is_navigation_finished():
			if target and global_position.distance_to(target.transform.origin) < 8.0:
				attack_position = target.transform.origin
				set_state(States.ATTACKING)
				attack_position = target.transform.origin + Vector3(0.0, 0.1, 0.0)

func on_path_changed():
	if health_system.health == 0.0:
		set_state(States.DYING)
		return

	if state == States.ATTACKING:
		return

	if animation_player.current_animation == ANI[LIST.IDLE]:
		animation_player.play(ANI[LIST.WALK])
		
	if animation_player.current_animation == ANI[LIST.HURT]:
		animation_player.play(ANI[LIST.WALK])

func on_attack_box_entered(body):
	if body.is_in_group('PlayerCharacter') or body.is_in_group('Goat'):
		var damage_successful = body.health_system.damage(attack_value, 4)
		if damage_successful && attack_box:
			attack_box.set_deferred('monitoring', false)


func _on_audio_stream_player_3d_ambient_finished() -> void:
	_play_new_random_ambient_sound()
