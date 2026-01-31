extends Node3D

@onready var startbutton: Button = %Startbutton


func _ready() -> void:
	pass # Replace with function body.
	startbutton.pressed.connect(func(): print('zzz'))
