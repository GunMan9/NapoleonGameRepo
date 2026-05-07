extends Control

@export var players_path: NodePath

var player = preload("res://Main/player.tscn")

var data = {
	"Coalition": [
		"British Empire"
	],
	"French Empire": [
		"France"
	]
}

var team1 = ""
var team2 = ""

signal roundui

func _ready():
	var coalition_list = data["Coalition"]
	var french_list = data["French Empire"]
	
	team1 = coalition_list[randi() % coalition_list.size()]
	team2 = french_list[randi() % french_list.size()]
	
	_assign_teams_to_nodes(team1, team2)
	
func _update_team_ui():
	var players_node = get_node(players_path)
	var team1_node = players_node.get_node("Team1")
	var team2_node = players_node.get_node("Team2")

	var bg = get_node("Background")
	var t1_button = bg.get_node("Team1_Button")
	var t2_button = bg.get_node("Team2_Button")

	var t1 = team1_node.get_meta("Team")
	var t2 = team2_node.get_meta("Team")
	
	print(team1_node.get_meta("Team"))
	print(team2_node.get_meta("Team"))

	var t1_count = team1_node.get_child_count()
	var t2_count = team2_node.get_child_count()

	t1_button.text = "%s (%d)" % [t1, t1_count]
	t2_button.text = "%s (%d)" % [t2, t2_count]
	
func _assign_teams_to_nodes(t1, t2):
	var players_node = get_node(players_path)
	var team1_node = players_node.get_node("Team1")
	var team2_node = players_node.get_node("Team2")

	team1_node.set_meta("Team", t1)
	team2_node.set_meta("Team", t2)

	_update_team_ui()
	
func _on_team_1_button_pressed() -> void:
	var players_node = get_node(players_path)
	var team1_node = players_node.get_node("Team1")
	var bg = get_node("Background")
	
	var team1_spawn = players_node.get_parent().get_node("Team1Spawn").get_node("Spawnpoint")
	
	var player_instance = player.instantiate()
	player_instance.global_position = team1_spawn.global_position
	team1_node.add_child(player_instance)
	_update_team_ui()
	roundui.emit()
	
	bg.visible = false

func _on_team_2_button_pressed() -> void:
	var players_node = get_node(players_path)
	var team2_node = players_node.get_node("Team2")
	var bg = get_node("Background")
	
	var team2_spawn = players_node.get_parent().get_node("Team2Spawn").get_node("Spawnpoint")
	
	var player_instance = player.instantiate()
	player_instance.global_position = team2_spawn.global_position
	team2_node.add_child(player_instance)
	_update_team_ui()
	roundui.emit()
	
	bg.visible = false

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Main/main_menu.tscn")
