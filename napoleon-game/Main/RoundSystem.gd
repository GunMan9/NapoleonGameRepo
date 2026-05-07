extends Control

var controlNode = get_parent()
var readyMenu = controlNode.get_node("CanvasLayer")
var readyButton = readyMenu.get_node("ReadyButton")
var startButton = readyMenu.get_node("StartButton")

var rData = {
	
}

func _on_ready_button_pressed() -> void:
	print("Ready button pressed")

func _on_start_button_pressed() -> void:
	pass # Replace with function body.
