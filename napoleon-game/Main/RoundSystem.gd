extends Control

@export var team_selector: NodePath
@export var players: NodePath

var ready_players := {}

@onready var startbutton = get_node("ReadyMenu/StartButton")
@onready var readybutton = get_node("ReadyMenu/ReadyButton")

func _ready():
	visible = false
	
	var ts = get_node(team_selector)
	ts.roundui.connect(_on_roundui)

	startbutton.text = "Start"
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
		if team.name == "Team1" or team.name == "Team2":
			for player in team.get_children():
				count += 1

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

func _on_roundui():
	visible = true
	update_start_button()
	update_status()

func _on_ready_button_pressed() -> void:
	var player_id = 1

	if ready_players.has(player_id):
		ready_players.erase(player_id)
		print("Player", player_id, "is now NOT ready")
	else:
		ready_players[player_id] = true
		print("Player", player_id, "is now READY")

	update_start_button()
	update_status()

func _on_start_button_pressed() -> void:
	var total = get_player_count()
	var ready = ready_players.size()

	if total > 0 and ready >= total:
		print("Game started!")
		SignalManager.game_started.emit()
		visible = false
	else:
		print("Cannot start yet:", ready, "/", total)
