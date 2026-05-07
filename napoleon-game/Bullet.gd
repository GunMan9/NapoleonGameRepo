extends CharacterBody3D

var speed = 30.0
var gravity = 9.8
var drag = 0.1

@onready var lifetime_timer := Timer.new()

func _ready():
	velocity = transform.basis * Vector3(0, 0, -speed)

	lifetime_timer.wait_time = 10.0
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free)
	add_child(lifetime_timer)
	lifetime_timer.start()

func _physics_process(delta):
	velocity.y -= gravity * delta
	velocity *= (1.0 - drag * delta)

	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		var parent = collider.get_parent()

		if parent and (parent.name == "Team1" or parent.name == "Team2"):
			var health = collider.get_node_or_null("HealthComponent")
			if health:
				health.take_damage(100)
			else:
				print("This is a dummy: cannot take away health.")

		queue_free()
