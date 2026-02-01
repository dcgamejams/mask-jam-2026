extends CharacterBody3D

class_name Goat

@onready var health_system: HealthSystem = $Health
@onready var navigation_system: NavigationSystem = $NavigationSystem

func _ready():
	add_to_group('Goat')
	health_system.signal_death.connect(goat_die)

	
func goat_die():
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	print("YOU KILLED MY GOAT")
	queue_free()
