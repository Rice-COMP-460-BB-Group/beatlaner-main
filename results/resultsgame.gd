extends Control

var display_time = 5.0
var buttons_enabled = false
@onready var timer = $CountdownTimer
@onready var progress_bar = $MainContainer/TimerSection/ProgressBar
@onready var timer_value_label = $MainContainer/TimerSection/TimerContainer/TimerValue

func _ready():
	if !has_node("CountdownTimer"):
		timer = Timer.new()
		timer.name = "CountdownTimer"
		add_child(timer)
	
	timer.wait_time = 5.0
	timer.one_shot = false
	
	timer.timeout.connect(_on_timer_timeout)
	
	progress_bar.value = 100
	timer_value_label.text = str(int(display_time))
	timer.start()

func _process(delta: float) -> void:
	timer_value_label.text = str(int(timer.time_left))
	progress_bar.value = timer.time_left

func _on_timer_timeout():
	enable_buttons()

func enable_buttons():
	if buttons_enabled:
		return
		
	buttons_enabled = true
	$MainContainer/ButtonsContainer/MainMenuButton.disabled = false
	$MainContainer/ButtonsContainer/ExitGameButton.disabled = false
	
	$MainContainer/ButtonsContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$MainContainer/ButtonsContainer/ExitGameButton.pressed.connect(_on_exit_game_pressed)

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://title/titlescreen.tscn")

func _on_exit_game_pressed():
	get_tree().quit()