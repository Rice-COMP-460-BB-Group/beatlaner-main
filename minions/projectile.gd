extends Area2D

@export var target: Node2D
@export var source: Node2D
@export var red: bool
var speed = 400
var damage = 10

func _ready():
	if red:
		$Projectile.texture = preload("res://assets/proj.png")
	else:
		$Projectile.texture = preload("res://assets/proj-enemy.png")
		
func _physics_process(delta):
	if not is_instance_valid(target):
		queue_free()
		return
		
	var direction = (target.global_position - global_position).normalized()
	position += direction * speed * delta
	rotation = direction.angle()

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
