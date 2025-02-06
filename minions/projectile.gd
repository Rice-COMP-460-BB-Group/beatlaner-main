extends Area2D

@export var target: Node2D
@export var source: Node2D
@export var red: bool = true
@export var speed = 400
@export var damage = 10

var syncPos: Vector2
var syncRotation: int

func _ready():
	if !red:
		$Projectile.texture = preload("res://assets/proj-enemy.png")
		$PointLight2D.color = Color(0, 0, 1, 1)
	if not multiplayer.is_server():
		syncPos = position
		syncRotation = rotation
		
func _physics_process(delta):
	if multiplayer.is_server():
		if not is_instance_valid(target):
			rpc("destroy_bullet")
			return
			
		var direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta
		rotation = direction.angle()
		syncPos = position
		syncRotation = rotation
	else:
		position = lerp(position, syncPos, 0.5)
		rotation = syncRotation

func _on_body_entered(body):
	if multiplayer.is_server():
		if body == target:
			if target.has_node("HealthComponent"):
				target.get_node("HealthComponent").rpc("decrease_health", damage)
			rpc("destroy_bullet")

@rpc("any_peer", "call_local")
func destroy_bullet():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if multiplayer.is_server():

		if area == target:
			if target.has_node("HealthComponent"):
				target.get_node("HealthComponent").rpc("decrease_health", damage)
			rpc("destroy_bullet")
