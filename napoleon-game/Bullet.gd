extends CharacterBody3D

var speed = 500.0
var gravity = 9.8
var drag = 0.1

func _ready():
	velocity = transform.basis * Vector3(0, 0, -speed)

func _physics_process(delta):
	velocity.y -= gravity * delta
	velocity *= (1.0 - drag * delta)

	var collision = move_and_collide(velocity * delta)
	
	if collision:
		print("Collided with:", collision.get_collider().name)
		queue_free()
