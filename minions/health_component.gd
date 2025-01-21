extends Node2D

class_name HealthComponent

signal health_destroyed

@export var currentHealth: int

@export var maxHealth: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
