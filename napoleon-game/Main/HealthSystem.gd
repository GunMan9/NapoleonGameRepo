extends Node
class_name HealthComponent

signal health_changed(current_health)

@export var max_health: int = 100
var current_health: int

var dead := false

func _ready():
	current_health = max_health
	health_changed.emit(current_health)

func take_damage(amount: int):
	if dead:
		return

	current_health = max(0, current_health - amount)
	health_changed.emit(current_health)

	if current_health <= 0:
		dead = true
		die()

func die():
	var parent = get_parent()
	var team_name = ""
	var team_node = parent.get_parent()

	if team_node:
		team_name = team_node.get_meta("Team")

	print("EMITTED:", team_name)
	SignalManager.died.emit(team_name)
	print("you ded lol")
