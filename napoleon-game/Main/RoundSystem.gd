extends Control

@export var team_selector: NodePath

func _ready():
	visible = false
	
	var ts = get_node(team_selector)
	ts.roundui.connect(_on_roundui)

func _on_roundui():
	visible = true
