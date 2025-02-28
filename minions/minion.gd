extends CharacterBody2D

class_name Minion

@export var tower_target: Node2D

var enemy_target: Node2D

var intermediate_lane: Node2D
var is_attacking = false

enum Team {BLUE, RED}

@export var team: Team

@export var ranged = true


var state: State
var level: int

enum State {MOVE, ATTACK, FROZEN}
enum BuffState {INCREASE, DECREASE}
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationHandler/NavigationAgent2D
@onready var attack_timer: Timer = $AttackTimer
@onready var sprite = $AnimatedSprite2D
@export var projectile_scene: PackedScene

@export var movement_speed = 75
@export var attack_speed: float = .5

var visited_intermediate = false

@export var aggro_range = 300
@export var attack_range = 300

var damage = 10

var syncPos: Vector2
var syncVelocity: Vector2 
var syncState: int

func _enter_tree():
	if team != Team.BLUE:
		$HealthComponent.red = false
	else:
		$HealthComponent.red = true

func _ready():
	attack_timer.wait_time = attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	$MultiplayerSpawner.spawn_function = fire
	$MultiplayerSpawner.spawn_path = get_parent().get_path()
	syncPos = position
	syncVelocity = velocity
	syncState = state


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


func set_level(level:int):
	print("[minion.gd]","level invoked")
	$HealthComponent.increase_max_health(10 * level)
	$HealthComponent.currentHealth = $HealthComponent.maxHealth
	$HealthComponent.display_level(level)
	damage += ceil((level * 1.5))
func get_health():
	return $HealthComponent.get_current_health()
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float):
	var mat = $AnimatedSprite2D.material
	var current_time = mat.get_shader_parameter("time")
	mat.set_shader_parameter("time", current_time + delta)

	if multiplayer.is_server():
		if not is_attacking:
			var anim_suffix = "friendly" if team != Team.BLUE else "enemy"
			var angle = velocity.angle()
			if abs(angle) <= PI / 4:
				sprite.play(anim_suffix + "_walk_right")
			elif abs(angle) >= 3 * PI / 4:
				sprite.play(anim_suffix + "_walk_left")
			elif angle < 0:
				sprite.play(anim_suffix + "_walk_up")
			else:
				sprite.play(anim_suffix + "_walk_down")

			if state == State.FROZEN:
				return
			if not is_instance_valid(tower_target):
				var towers = get_tree().get_nodes_in_group("Towers")
				var nexus = get_tree().get_nodes_in_group("Nexus")
				for i in nexus:
					towers.append(i)
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
				elif global_position.distance_to(enemy_target.global_position) < aggro_range:
					if attack_timer.is_stopped():
						print("begin attacking")
						attack_timer.start()
			
			var current_agent_position = global_position
			var next_path_position = navigation_agent_2d.get_next_path_position()
			var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed
			
			if state == State.MOVE:
				var space_state = get_world_2d().direct_space_state
				var query = PhysicsShapeQueryParameters2D.new()
				
				# Set up rectangle shape
				var shape = RectangleShape2D.new()
				shape.extents = Vector2(aggro_range, 100)
				query.shape = shape
				query.transform = Transform2D(current_agent_position.direction_to(next_path_position).angle(), global_position)
				query.exclude = [self]
				query.collide_with_bodies = true
				query.collide_with_areas = true

				var results = space_state.intersect_shape(query)
				for result in results:
					if result.collider is Player and result.collider.team != team:
						print("player found")
						set_enemy_target(result.collider)
						state = State.ATTACK
						return
					if result.collider is Minion and result.collider.get_team() != team:
						print("enemy found")
						set_enemy_target(result.collider)
						state = State.ATTACK
						return
					if result.collider is Tower and result.collider.team != team:
						print("tower found")
						set_enemy_target(result.collider)
						state = State.ATTACK
						return
					if result.collider is Nexus and result.collider.team != team:
						print("[minion.gd] nexus found")
						set_enemy_target(result.collider)
						state = State.ATTACK
						return
			if navigation_agent_2d.is_navigation_finished():
				print("reached target")
				return
			# stop moving if we are close to the target
			if state == State.ATTACK and global_position.distance_to(enemy_target.global_position) < attack_range:
				new_velocity = Vector2.ZERO
			
			if navigation_agent_2d.avoidance_enabled:
				navigation_agent_2d.set_velocity(new_velocity)
			else:
				_on_navigation_agent_2d_velocity_computed(new_velocity)
			move_and_slide()
			syncPos = position
			syncVelocity = velocity
			syncState = state
			
			
			
	else:
		if position.distance_to(syncPos) > 1:
			position = position.lerp(syncPos, 0.5)
			velocity = velocity.lerp(syncVelocity, 0.5)
			state = syncState

func fire(dict):
	print('FIRED')
	var projectile = projectile_scene.instantiate()
	projectile.red = team != Team.RED
	projectile.target = enemy_target
	projectile.global_position = global_position
	projectile.source = self
	projectile.damage = damage
	$HitAudio.play()
	return projectile
	
@rpc("authority")
func _on_attack_timer_timeout():
	print("attempting attack on enemy")
	print(is_instance_valid(enemy_target))
	var anim_suffix = "friendly" if team != Team.BLUE else "enemy"
	if is_instance_valid(enemy_target) && global_position.distance_to(enemy_target.global_position) < attack_range:
		print("ranged", ranged)
		
		sprite.play(anim_suffix + "_attack")
		is_attacking = true
		if ranged:
			print('spawning')
			print("MultiplayerSpawner function set to:", $MultiplayerSpawner.spawn_function)
			$MultiplayerSpawner.spawn({"dummy": true})
			#fire.rpc()
		else:
			var health_component = enemy_target.get_node("HealthComponent")
			if health_component and health_component is HealthComponent:
				$HitAudio.play()
				health_component.rpc("decrease_health", damage*1.5)

func _on_animated_sprite_2d_animation_finished():
	is_attacking = false
	
	var anim_suffix = "friendly" if team != Team.BLUE else "enemy"
	var angle = velocity.angle()
	if abs(angle) <= PI / 4:
		sprite.play(anim_suffix + "_walk_right")
	elif abs(angle) >= 3 * PI / 4:
		sprite.play(anim_suffix + "_walk_left")
	elif angle < 0:
		sprite.play(anim_suffix + "_walk_up")
	else:
		sprite.play(anim_suffix + "_walk_down")

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func process_status(status: String) -> void:
	print("processing status")
	if status == "freeze":
		state = State.FROZEN
		$FreezeParticle.emitting = true
	if status == "mutiny":
		#idea: random chance -> flip team for a few seconds
		print("placeholder")
		
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = 5.0
	timer.timeout.connect(_clear_status)
	timer.start()
	

func _clear_status():
	state = State.MOVE
	$FreezeParticle.emitting = false
func _on_timer_timeout() -> void:
	pass # Replace with function body.
	
func process_damage_powerup():
	damage *= 2
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = 5.0
	timer.timeout.connect(_reset_damage)
	timer.start()

	$DamageParticle.emitting = true

	$AnimatedSprite2D.material.set_shader_parameter("fade", 0.0)
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/fade", 1.0, 1.0)
			


func _reset_damage():
	damage = 10
	print("Power-up expired. Damage reset to:", damage)

	$DamageParticle.emitting = false

	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/fade", 0.0, 1.0)
	
@rpc("any_peer", "call_local")
func die():
	queue_free()


func _on_health_component_health_destroyed() -> void:
	rpc("die")
