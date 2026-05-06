extends CharacterBody3D
var inital_rotation
var speed: float = 10
func _ready() -> void:
	inital_rotation = rotation
	
func _physics_process(delta: float) -> void:
	##position.x = 
	##move_and_slide()
	##rotation = inital_rotation
	pass


func _on_body_entered():
	queue_free()
