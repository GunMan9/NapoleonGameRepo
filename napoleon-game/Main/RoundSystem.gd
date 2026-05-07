extends Control

@export var team_selector: NodePath
@export var players: NodePath

var ready_players := {}

var round_timer: Timer
var round_time_left := 0

var team1_tickets = 1000
var team2_tickets = 1000

@onready var startbutton = get_node("ReadyMenu/StartButton")
@onready var readybutton = get_node("ReadyMenu/ReadyButton")

@onready var round_info = get_node("RoundInfo")
@onready var timer_label = get_node("RoundInfo/Timer")
@onready var t1_tickets_label = get_node("RoundInfo/Team1_Tickets")
@onready var t2_tickets_label = get_node("RoundInfo/Team2_Tickets")


func _ready():
	add_to_group("round_manager")

	get_node("ReadyMenu").visible = false
	get_node("RoundInfo").visible = false
	get_node("GB_Victory").visible = false

	round_timer = Timer.new()
	round_timer.one_shot = false
	round_timer.wait_time = 1.0
	round_timer.timeout.connect(_on_round_timer_tick)
	add_child(round_timer)

	_sync_tickets_ui()

	if not SignalManager.died.is_connected(_on_player_died):
		SignalManager.died.connect(_on_player_died)

	call_deferred("_connect_team_selector")


func _connect_team_selector():
	var ts = get_node_or_null(team_selector)
	if ts and ts.has_signal("roundui"):
		ts.roundui.connect(_on_roundui)


func _sync_tickets_ui():
	t1_tickets_label.text = str(team1_tickets)
	t2_tickets_label.text = str(team2_tickets)


func _on_player_died(team_name: String):

	print("RECEIVED:", team_name)

	if team_name == "British Empire":
		team1_tickets -= 1
		print("Removing ticket from British Empire")

	elif team_name == "France":
		team2_tickets -= 1
		print("Removing ticket from France")

	_sync_tickets_ui()

	if team1_tickets <= 0:
		end_game("France")

	elif team2_tickets <= 0:
		end_game("British Empire")


func _on_roundui():
	get_node("ReadyMenu").visible = true
	update_start_button()
	update_status()


func _on_ready_button_pressed() -> void:
	var player_id = 1

	if ready_players.has(player_id):
		ready_players.erase(player_id)
	else:
		ready_players[player_id] = true

	update_start_button()
	update_status()


func update_status():
	var player_id = 1

	if ready_players.has(player_id):
		readybutton.text = "Status: Ready"
	else:
		readybutton.text = "Status: Not Ready"


func get_player_count() -> int:
	var players_node = get_node(players)
	var count := 0

	for team in players_node.get_children():
		count += team.get_child_count()

	return count


func update_start_button():
	var ready_count = ready_players.size()
	var total_count = get_player_count()

	if total_count == 0:
		startbutton.text = "Start"
	elif ready_count < total_count:
		startbutton.text = "Cannot Start (%d/%d)" % [ready_count, total_count]
	else:
		startbutton.text = "Start"

	startbutton.disabled = ready_count < total_count


func _on_start_button_pressed() -> void:
	var total = get_player_count()
	var ready = ready_players.size()

	if total > 0 and ready >= total:
		SignalManager.game_started.emit()
		get_node("ReadyMenu").visible = false
		get_node("RoundInfo").visible = true
		_start_round_timer()


func _start_round_timer():
	round_time_left = 1 * 60
	round_timer.start()
	update_timer_ui()


func _on_round_timer_tick():
	round_time_left -= 1
	update_timer_ui()

	if round_time_left <= 0:
		round_timer.stop()

		if team1_tickets > team2_tickets:
			end_game("British Empire")

		elif team2_tickets > team1_tickets:
			end_game("France")

		else:
			end_game(["British Empire", "France"].pick_random())


func update_timer_ui():
	var minutes = int(round_time_left / 60)
	var seconds = round_time_left % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func end_game(winning_team: String):

	if round_timer:
		round_timer.stop()

	if winning_team == "British Empire":
		var GB_Win_Screen = get_node("GB_Victory")
		var RoundInfo = get_node("RoundInfo")
		var GB_Win_Song = get_node("GB_Victory/RuleBritannia")

		GB_Win_Screen.visible = true
		RoundInfo.visible = false
		GB_Win_Song.play()
		
	if winning_team == "France":
		print("France won")

	SignalManager.round_ended.emit()

	get_node("RoundInfo").visible = false
	get_node("ReadyMenu").visible = true

func _on_round_end():
	end_game("Draw")
