extends StaticBody2D
class_name Nexus
enum Team {BLUE,RED}
var team = Team.BLUE
var minion_count = 0
var last_attack = -1
var attack_speed = .17
@export var laser_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MultiplayerSpawner.spawn_function = fire
	$MultiplayerSpawner.spawn_path = get_parent().get_path()
	$AnimatedSprite2D.play()


func set_team(new_team:Team):
	team = new_team
	if (team == Team.RED):
		$AnimatedSprite2D.animation = "anim_blue"
		
	else:
		$AnimatedSprite2D.animation = "anim_red"
		
	$AnimatedSprite2D.play()

func get_team()-> Team:
	return team
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fire(dict):
	print('FIRED', multiplayer.is_server())
	var body_id = dict["body"]
	var body = instance_from_id(body_id)
	var laser = laser_scene.instantiate()
	if laser is Laser:
		laser.set_team(team)
	print("attacking with laser")
	laser.target = body
	laser.source = self
	laser.global_position = global_position
	return laser

func _physics_process(delta: float) -> void:
	if last_attack < 0 or last_attack > attack_speed:
		var enemy_minions = []
		for body in $EnemyDetectArea.get_overlapping_bodies():
			if (body is Minion or body is Player) and body.team != team:
				var space_state = get_world_2d().direct_space_state
				var query = PhysicsRayQueryParameters2D.create(global_position, body.global_position, (1 | 4), [self])

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
			
			attack.rpc(enemy_minions[0])
	else:
		last_attack += delta

func _on_detection_area_body_entered(body: Node2D) -> void:
	print("[nexus.gd]","body entered")
	if body is Player:
		print("[nexus.gd]","hey player")
		print("[nexus.gd]",body.team,"team",team)
		if body.team == team:
			 
			body.can_use_nexus = true
			body.show_tooltip(KEY_M, "Upgrade minions")
			body.show_tooltip(KEY_N, "Upgrade yourself")

func _on_health_component_health_destroyed() -> void:

	print("nexus destroyed" + str(team))
	Signals.NexusDestroyed.emit(team, global_position)
	queue_free()



func _on_detection_area_body_exited(body: Node2D) -> void:
	print("[nexus.gd]","body exited")
	if body is Player:
		if body.team == team:
			body.can_use_nexus = false
			body.hide_tooltip(KEY_M)
			body.hide_tooltip(KEY_N)
@rpc("any_peer", "call_local")
func attack(body: Node2D) -> void:
	print("[nexus.gd]is server", multiplayer.is_server())
	var body_id = body.get_instance_id()
	$MultiplayerSpawner.spawn({"body": body_id})
	$LaserShooter.play()
	
