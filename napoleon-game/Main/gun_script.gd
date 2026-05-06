extends Node3D
@onready var gun_mesh: MeshInstance3D = $GunMesh
@onready var firepoint: Node3D = $firepoint

var isloaded: bool = true
var isreloading: bool = false
var bullet=preload("res://Main/Bullet.tscn")
func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Fire_Gun"):
		var bulet = bullet.instantiate()
		bulet.position = global_position
		bulet.transform = global_transform
		get_parent().add_child(bulet)
		
