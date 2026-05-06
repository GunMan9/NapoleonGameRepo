extends CharacterBody3D

var speed = 250.0
var gravity = 9.8
var drag = 0.1

func _ready():
	velocity = transform.basis * Vector3(0, 0, -speed)

func _physics_process(delta):
	velocity.y -= gravity * delta
	velocity *= (1.0 - drag * delta)

	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		var parent = collider.get_parent()
	
		if parent and (parent.name == "Team1" or parent.name == "Team2"):
			if collider.get_node("HealthComponent"):
				collider.get_node("HealthComponent").take_damage(100)
			else:
				print("This is a dummy: cannot take away health.")
			queue_free()
