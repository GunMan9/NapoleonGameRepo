extends Node
class_name HealthComponent

signal health_changed(current_health)
signal died

@export var max_health: int = 100
var current_health: int

func _ready():
	current_health = max_health
	health_changed.emit(current_health)

func take_damage(amount: int):
	print("Damage taken:", amount)
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health)
	
	if current_health == 0:
		died.emit()
