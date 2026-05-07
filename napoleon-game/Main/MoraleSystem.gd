extends Node
class_name MoraleComponent

signal morale_changed(current_morale)
signal morale_zero

@export var max_morale: int = 100
@export var health_component: HealthComponent

var current_morale: int
var timer: Timer
var active := false

func _ready():
	current_morale = max_morale
	morale_changed.emit(current_morale)

	timer = Timer.new()
	timer.wait_time = 1
	timer.one_shot = false
	add_child(timer)

	timer.timeout.connect(_on_morale_tick)

	SignalManager.game_started.connect(_on_game_started)

func _on_game_started():
	active = true
	timer.start()

func _on_morale_tick():
	if not active:
		return
		
	if is_team_in_line(3):
		gain_morale()
	else:
		lose_morale()
	
func is_team_in_line(min_count: int) -> bool:
	var team = get_parent().get_parent()
	if team == null:
		return false

	var positions = []

	for member in team.get_children():
		if member.has_method("get_global_position"):
			positions.append(member.global_position)

	if positions.size() < min_count:
		return false

	positions.sort_custom(func(a, b): return a.x < b.x)

	var tolerance := 1.5

	for i in range(min_count - 1):
		if abs(positions[i].x - positions[i + 1].x) > tolerance:
			return false

	return true

func gain_morale():
	current_morale = min(max_morale, current_morale + 1)
	morale_changed.emit(current_morale)

func lose_morale():
	if is_team_in_line(3):
		return

	current_morale = max(0, current_morale - 1)
	morale_changed.emit(current_morale)

	if current_morale == 0:
		morale_zero.emit()

		if health_component:
			health_component.take_damage(1)
