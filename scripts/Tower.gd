extends Node2D

class_name Tower

enum Team {BLUE, RED}

@export var team: Team
@export var laser_scene: PackedScene

@onready var popup_window = $Window
@onready var surrender_scene = preload("res://map/surrender.tscn")
var rhythm_game_instance

var minion_count = 0
var last_attack = -1
var attack_speed = 3

func update_score(new_score: int):
	minion_count += int(pow(new_score / 10000.0, 0.6))
	print("fake minion count", minion_count)
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

func _physics_process(delta: float) -> void:
	if last_attack < 0 or last_attack > attack_speed:
		var enemy_minions = []
		for body in $DetectionArea.get_overlapping_bodies():
			if body is Minion and body.team != team:
				var space_state = get_world_2d().direct_space_state
				var query = PhysicsRayQueryParameters2D.create(global_position, body.global_position, (1 | 3), [self])

				var result = space_state.intersect_ray(query)
				if result and result.collider == body:
					enemy_minions.append(body)
		
		if enemy_minions.size() > 0:
			enemy_minions.sort_custom(
			func(a, b):
				var distance_a = global_position.distance_to(a.global_position)
				var distance_b = global_position.distance_to(b.global_position)
				return distance_b - distance_a
			)
			last_attack = 0
			attack(enemy_minions[0])
	else:
		last_attack += delta

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

func attack(body: Minion) -> void:
	var laser = laser_scene.instantiate()
	print("attacking with laser")
	laser.target = body
	laser.source = self
	laser.global_position = global_position
	get_tree().root.add_child(laser)
