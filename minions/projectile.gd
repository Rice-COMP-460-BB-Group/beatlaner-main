class_name Laser
extends Area2D

@export var target: Node2D
@export var source: Node2D
@export var red: bool = true
@export var speed = 400
@export var damage = 10
var direction
enum Team {BLUE,RED}
var syncPos: Vector2
var syncRotation: float

func _ready():
	if !red:
		$Projectile.texture = preload("res://assets/proj-enemy.png")
		$PointLight2D.color = Color(0, 0, 1, 1)
	if is_instance_valid(target):

		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()
	syncPos = position
	syncRotation = rotation
func _physics_process(delta):
	if multiplayer.is_server():
		if not is_instance_valid(target) or ( is_instance_valid(target)  and target.has_node("HealthComponent") and target.get_node("HealthComponent").get_current_health() <= 0):
			rpc("destroy_bullet")
			return
			

		if target is not Player:
			direction = (target.global_position - global_position).normalized()
			position += direction * speed * delta
			rotation = direction.angle()
		else:
			position += direction * speed * delta
		syncPos = position
		syncRotation = rotation
	else:
		if position.distance_to(syncPos) > 1:
			position = lerp(position, syncPos, 0.5)
			rotation = lerpf(rotation, syncRotation, 0.5)
func set_team(team: Team):
	if team == Team.BLUE:
		$Projectile.modulate = Color(5,0,0)
	else:
		$Projectile.modulate = Color(0,0,5)
func _on_body_entered(body):
	if multiplayer.is_server():
		if body == target:
			if target.has_node("HealthComponent"):
				target.get_node("HealthComponent").rpc("decrease_health", damage)
			rpc("destroy_bullet")

@rpc("any_peer", "call_local")
func destroy_bullet():
	print("destroyed")
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if multiplayer.is_server():
		if area == target:
			if target.has_node("HealthComponent"):
				target.get_node("HealthComponent").rpc("decrease_health", damage)
			rpc("destroy_bullet")
