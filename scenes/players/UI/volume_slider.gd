extends HBoxContainer

@onready var volume: HSlider = %Volume

var bus_master = AudioServer.get_bus_index("Master")
var volume_master_value: float

func _ready() -> void:
	volume_master_value = db_to_linear(AudioServer.get_bus_volume_db(bus_master))
	volume.max_value = 1.0 * 2
	volume.value = volume_master_value
	volume.value_changed.connect(_on_master_value_changed)

	
func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(bus_master, linear_to_db(value))
