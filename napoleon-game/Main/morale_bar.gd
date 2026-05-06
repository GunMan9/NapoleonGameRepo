extends ProgressBar

@export var morale_component: MoraleComponent

func _ready():
	max_value = morale_component.max_morale
	value = morale_component.current_morale
	
	morale_component.morale_changed.connect(_on_morale_changed)
	
func _on_morale_changed(new_morale):
	value = new_morale
