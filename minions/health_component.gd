extends Node2D

class_name HealthComponent

signal health_destroyed

@export var currentHealth: int

@export var maxHealth: int

@export var red: bool = true

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !red:
		$HealthBar.texture_under = preload("res://assets/healthbar/health-outline-blue.png")
		$HealthBar.texture_progress = preload("res://assets/healthbar/health-mask-blue.png")
		$CanvasModulate.modulate = Color(1.4, 1.4, 1.4, 1.0)
	
	$HealthBar.update(currentHealth, maxHealth)


func get_current_health():
	return currentHealth

func get_max_health():
	return maxHealth


@rpc("any_peer", "call_local")
func decrease_health(amount: int):
	if has_node("HealthBar"):
		print("Found HealthBar for", get_parent().name)
		$HealthBar.update(currentHealth, maxHealth)
	else:
		print("HealthBar not found for", get_parent().name)
	currentHealth -= amount
	if currentHealth <= 0 and !dead:
		dead = true
		print("health is zero")
		currentHealth = 0
		health_destroyed.emit()
		
	$HealthBar.update(currentHealth, maxHealth)

func reset_health():
	currentHealth = maxHealth
	dead = false
	$HealthBar.update(currentHealth, maxHealth)
