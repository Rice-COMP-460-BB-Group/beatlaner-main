extends Area2D

@export var target: Node2D
@export var source: Node2D
@export var red: bool = true
@export var speed = 400
@export var damage = 10
var direction

func _ready():
	if !red:
		$Projectile.texture = preload("res://assets/proj-enemy.png")
		$PointLight2D.color = Color(0, 0, 1, 1)
	direction = (target.global_position - global_position).normalized()
	rotation = direction.angle()
		
func _physics_process(delta):
	if not is_instance_valid(target) or (target.has_node("HealthComponent") and target.get_node("HealthComponent").dead):
		queue_free()
		return
		
	if target is not Player:
		direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta
		rotation = direction.angle()
	else:
		position += direction * speed * delta


func _on_body_entered(body):
	if body == target:
		if target.has_node("HealthComponent"):
			target.get_node("HealthComponent").decrease_health(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area == target:
		if target.has_node("HealthComponent"):
			target.get_node("HealthComponent").decrease_health(damage)
		queue_free()
