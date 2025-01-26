extends Node2D

class_name HealthComponent

signal health_destroyed

@export var currentHealth: int

@export var maxHealth: int

@export var red: bool = true

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


func decrease_health(amount: int):
	currentHealth -= amount
	if currentHealth <= 0:
		print("health is zero")
		currentHealth = 0
		health_destroyed.emit()
		
	$HealthBar.update(currentHealth, maxHealth)
