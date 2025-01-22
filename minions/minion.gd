extends CharacterBody2D

class_name Minion

@export var tower_target: Tower

var enemy_target: Node2D

var intermediate_lane: Node2D

enum Team {BLUE, RED}

@export var team: Team

var speed = 300
var accel = 5

var state: State
enum State {MOVE, ATTACK}

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationHandler/NavigationAgent2D
@onready var attack_timer: Timer = $AttackTimer

var movement_speed = 250
@export var attack_speed: float = .5

var visited_intermediate = false

func _ready():
	attack_timer.wait_time = attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func get_team() -> int:
	return team

func set_team(is_player: bool):
	if is_player:
		team = Team.BLUE
	else:
		team = Team.RED

func get_tower_target():
	return tower_target

func set_tower_target(node: Node2D):
	tower_target = node

func get_enemy_target():
	return enemy_target

func set_enemy_target(node: Node2D):
	enemy_target = node

func get_health():
	return $HealthComponent.get_current_health()

@warning_ignore("unused_parameter")
func _physics_process(delta: float):

	if not is_instance_valid(tower_target):
		var towers = get_tree().get_nodes_in_group("Towers")
		var candid = null
		var min_dist = INF
		for tower in towers:
			if tower.team != team:
				var distance = global_position.distance_to(tower.global_position)
				if distance < min_dist:
					min_dist = distance
					candid = tower
		print("finding new tower")
		tower_target = candid

	if state == State.MOVE || enemy_target == null:
		if enemy_target == null:
			state = State.MOVE
			
		if intermediate_lane and not visited_intermediate:
			navigation_agent_2d.target_position = intermediate_lane.position
			if global_position.distance_to(intermediate_lane.position) < 5:
				visited_intermediate = true
		else:
			if tower_target == null:
				return
			navigation_agent_2d.target_position = tower_target.position
	else:
		navigation_agent_2d.target_position = enemy_target.global_position

		var health_component = enemy_target.get_node("HealthComponent")

		if health_component and health_component is HealthComponent and health_component.currentHealth <= 0:
			enemy_target = null
			state = State.MOVE
			print("stopped aggroing")
		elif global_position.distance_to(enemy_target.global_position) < 75:
			if attack_timer.is_stopped():
				print("begin attacking")
				attack_timer.start()
	
	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	
	if state == State.MOVE:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.new()
		query.collide_with_areas = true
		query.from = global_position
		query.to = global_position + new_velocity.normalized() * 200
		query.exclude = [self]
		
		var result = space_state.intersect_ray(query)
		print(result)
		if result and result.collider is Minion and result.collider.get_team() != team:
			print("enemy found")
			set_enemy_target(result.collider)
			state = State.ATTACK
			return
		if result and result.collider is Tower and result.collider.team != team:
			print("tower found")
			set_enemy_target(result.collider)
			state = State.ATTACK
			return
	if navigation_agent_2d.is_navigation_finished():
		print("reached target")
		return
	if state == State.ATTACK and global_position.distance_to(enemy_target.global_position) < 50:
		new_velocity = Vector2.ZERO
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	move_and_slide()

func _on_attack_timer_timeout():
	print("attempting attack on enemy")
	print(is_instance_valid(enemy_target))
	if is_instance_valid(enemy_target) && global_position.distance_to(enemy_target.global_position) < 75:
		var health_component = enemy_target.get_node("HealthComponent")
		if health_component and health_component is HealthComponent:
			print("attacking")
			health_component.decrease_health(randfn(10, 1.5))

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity


func _on_timer_timeout() -> void:
	pass # Replace with function body.

func _on_health_component_health_destroyed() -> void:
	queue_free()