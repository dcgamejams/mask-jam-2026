extends CanvasLayer

@export var health: HealthSystem
@onready var health_label: Label = %HealthLabel
@onready var health_bar: ProgressBar = %HealthBar

func _ready():
	health.signal_max_health_updated.connect(_on_health_max)
	health.signal_health_updated.connect(_on_health_updated)
	
func _on_health_max(new_max):
	health_bar.max_value = new_max
	health_bar.value = new_max
	health_bar.max_value = new_max
	health_bar.value = new_max
	health_label.text = str(new_max)
	
func _on_health_updated(next_health):
	health_bar.value = next_health
	health_label.text = str(next_health)
	  
