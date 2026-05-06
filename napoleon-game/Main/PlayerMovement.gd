extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002

enum FireState {
	IDLE,
	PREPARE,
	AIM
}

var fire_state := FireState.IDLE

var is_loaded := true
var is_reloading := false
var reload_time := 15.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $Camera3D

@export var health_component: HealthComponent
@export var morale_component: MoraleComponent

var bullet = load("res://Main/bullet.tscn")
@onready var pos = $Camera3D/Gun/pos

var rotation_x := 0.0

func _ready():
	await get_tree().process_frame
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func get_spread_direction(base_direction: Vector3) -> Vector3:
	if morale_component == null:
		return base_direction

	var morale_ratio = float(morale_component.current_morale) / morale_component.max_morale
	var morale_spread = 1.0 - morale_ratio

	var movement_speed = velocity.length() / speed
	var movement_spread = clamp(movement_speed, 0.0, 1.0)

	var spread_strength = morale_spread + movement_spread * 0.8

	var max_angle_deg = 10.0
	var angle = deg_to_rad(max_angle_deg * spread_strength)

	var yaw = randf_range(-angle, angle)
	var pitch = randf_range(-angle, angle)

	var dir = base_direction
	dir = dir.rotated(Vector3.UP, yaw)
	dir = dir.rotated(Vector3.RIGHT, pitch)

	return dir.normalized()

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.x = rotation_x

	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if fire_state == FireState.IDLE and is_loaded and not is_reloading:
			fire_state = FireState.PREPARE
			print("Prepared")
		elif not is_loaded:
			print("Not loaded!")

	if Input.is_action_just_pressed("click"):
		if fire_state == FireState.PREPARE:
			fire_state = FireState.AIM
			print("Aiming...")

		elif fire_state == FireState.AIM:
			if is_loaded and not is_reloading:
				var instance = bullet.instantiate()
				instance.position = pos.global_position

				var base_dir = -pos.global_transform.basis.z
				var spread_dir = get_spread_direction(base_dir)

				instance.transform.basis = Basis.looking_at(spread_dir, Vector3.UP)

				get_parent().add_child(instance)

				is_loaded = false
				fire_state = FireState.IDLE
				print("Fire!")
			else:
				print("Not loaded!")

	if Input.is_action_just_pressed("reload"):
		if not is_loaded and not is_reloading:
			start_reload()
			fire_state = FireState.IDLE
		elif is_loaded:
			print("Already loaded")	

	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func start_reload():
	is_reloading = true
	print("Reloading...")

	await get_tree().create_timer(reload_time).timeout

	is_loaded = true
	is_reloading = false
	print("Reloaded!")
