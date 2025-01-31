extends Node2D

class_name Tower

enum Team {BLUE, RED}

@export var team: Team
@onready var popup_window = $Window
@onready var surrender_scene = preload("res://map/surrender.tscn")
var rhythm_game_instance

var minion_count = 0

func update_score(new_score: int):
	minion_count += int(pow(new_score / 10000.0, 0.6))
	$MinionCount.text = "[center]" + str(minion_count) + "[/center]"
	if minion_count:
		$MinionCount.show()
	else:
		$MinionCount.hide()

func WaveSpawned():
	minion_count = 0
	$MinionCount.hide()

func _ready():
	
	$Sprite2D.centered = true
	popup_window.hide()
	popup_window.size = Vector2(1152, 648)
	Signals.WaveSpawned.connect(WaveSpawned)


func _on_health_component_health_destroyed() -> void:
	var viewport = get_viewport()
	if $VisibleOnScreenNotifier2D.is_on_screen():
		var camera = viewport.get_camera_2d()
		if camera:
			pass
	var surrender_instance = surrender_scene.instantiate()
	get_parent().add_child(surrender_instance)
	surrender_instance.global_position = global_position
	print("tower destroyed" + str(team))
	Signals.TowerDestroyed.emit(team)
	queue_free()

func _on_button_pressed() -> void:
	Signals.OpenRhythmGame.emit(name, self)
