extends CanvasLayer

@export var health: HealthSystem
@onready var health_label: Label = %HealthLabel
@onready var health_bar: ProgressBar = %HealthBar

@onready var goat_bar: ProgressBar = %GoatBar
@onready var goat_health_label: Label = %GoatHealthLabel

@onready var goat: Goat = get_tree().get_first_node_in_group('Goat')
@onready var camera_holder: CameraObject = %CameraHolder

@onready var mask_timer: Timer = Timer.new()
@onready var health_color_timer: Timer = Timer.new()


@onready var in_game_menu: MarginContainer = %InGameMenu
@onready var control: Control = %Control
@onready var volume: HSlider = %Volume
@onready var restart_button: Button = %RestartButton

var bus_master = AudioServer.get_bus_index("Master")
var volume_master_value: float
var ui_mask_on: bool = false

func _ready():
	health.signal_max_health_updated.connect(_on_health_max)
	health.signal_health_updated.connect(_on_health_updated)
	
	goat.health_system.signal_max_health_updated.connect(_on_goat_health_max)
	goat.health_system.signal_health_updated.connect(_on_goat_health_updated)
	goat.health_system.signal_max_health_updated.emit(1000)
	
	add_child(mask_timer)
	mask_timer.wait_time = 0.2
	mask_timer.timeout.connect(on_mask_hurt)

	add_child(health_color_timer)
	health_color_timer.wait_time = 0.2
	health_color_timer.one_shot = true
	health_color_timer.timeout.connect(color_fix)


	camera_holder.signal_mask_on.connect(mask_hurt_start)
	in_game_menu.hide()
	
	volume_master_value = db_to_linear(AudioServer.get_bus_volume_db(bus_master))
	volume.max_value = 1.0 * 2
	volume.value = volume_master_value
	volume.value_changed.connect(_on_master_value_changed)

	restart_button.pressed.connect(func(): get_tree().reload_current_scene())
	
func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(bus_master, linear_to_db(value))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab") and in_game_menu.visible == false:
		in_game_menu.show()
		control.mouse_filter = Control.MOUSE_FILTER_STOP
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_parent().immobile = true
	elif event.is_action_pressed("tab") and in_game_menu.visible == true:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		in_game_menu.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_parent().immobile = false


func mask_hurt_start(is_currently_on):
	ui_mask_on = is_currently_on
	if is_currently_on:
		mask_timer.start()
	else:
		mask_timer.stop()
		color_fix()

func on_mask_hurt():
	health.damage(1, 88)
	
func _on_health_max(new_max):
	health_bar.max_value = new_max
	health_bar.value = new_max
	health_bar.max_value = new_max
	health_bar.value = new_max
	health_label.text = str(new_max)


func _on_health_updated(next_health):
	if next_health < health_bar.value:
		health_bar["theme_override_styles/fill"].bg_color = Color.CORAL
		health_color_timer.start()

	health_bar.value = next_health
	health_label.text = str(next_health)

func _on_goat_health_max(new_max):
	goat_bar.max_value = new_max
	goat_bar.value = new_max
	goat_bar.max_value = new_max
	goat_bar.value = new_max
	goat_health_label.text = str(new_max)
	
func color_fix():
	if not ui_mask_on:
		health_bar["theme_override_styles/fill"].bg_color = Color.WHITE

func _on_goat_health_updated(next_health):
	goat_bar.value = next_health
	goat_health_label.text = str(next_health)
	if next_health <= 1000:
		%GoatHurt.show()
		await get_tree().create_timer(0.5).timeout
		%GoatHurt.hide()
