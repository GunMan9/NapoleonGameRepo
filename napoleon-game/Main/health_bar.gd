extends ProgressBar

@export var health_component: HealthComponent

func _ready():
	max_value = health_component.max_health
	value = health_component.current_health
	
	health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health):
	value = new_health
