extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Main/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	var credits = get_node("Credits")
	credits.visible = true

func _on_back_pressed() -> void:
	var credits = get_node("Credits")
	credits.visible = false
