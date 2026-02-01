extends Node3D

@export var enemy_data: Array[Wave]

@export var current_wave: int

var outstanding_sequences: int = 0

var WavesAreDone : bool = false

signal _ready_for_next_wave

func _pick_random_point() -> Vector3:
	#var point = Vector3(0,0,0)
	var random_child:Node3D = get_children().pick_random()
	var point: Vector3 = random_child.position
	
	return point

func _do_sequence(sequence: EnemySequence) -> void:
	outstanding_sequences += 1
	for i in sequence.EnemyAmount:
		await get_tree().create_timer(sequence.EnemySpawnInterval, false).timeout
		
		#pick a random spawn point
		#spawm enemy at that point
		var newEnemy:Enemy = sequence.EnemyScene.instantiate()
		newEnemy.position = _pick_random_point()
		add_child(newEnemy)

	# If we were the last sequence, signal to the wave manager that we're
	# ready for the next wave
	outstanding_sequences -= 1
	if outstanding_sequences <= 0:
		_ready_for_next_wave.emit()
	
func _ready() -> void:
	Global.signal_start.connect(startSpawning)
	
func startSpawning():
	print("thing is loaded")
	
	Global.MAX_WAVES = enemy_data.size()
	
	current_wave = 0
	for wave in enemy_data:
		await get_tree().create_timer(wave.SecondsTillNextWave, false).timeout
		
		# Spawn coroutine for each spawner
		for sequence in wave.enemy_sequences:
			_do_sequence(sequence)
		
		await _ready_for_next_wave
		current_wave += 1
		current_wave = min(current_wave, enemy_data.size())
		
	WavesAreDone = true
	
func _process(delta: float) -> void:
	
	
	if WavesAreDone == true:
		pass
