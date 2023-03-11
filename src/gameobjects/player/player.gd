extends CharacterBody3D

var ground_friction := 0.8
var air_friction := 0.99

var ground_acceleration := 0.75
var air_acceleration := 0.02

var jump_velocity := 4.0

var base_mouse_sensitivity := 0.0027
var base_joypad_sensitivity := 0.015

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity := 1.0
var joypad_sensitivity := 1.0

var joypad_look = Vector2.ZERO


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta):
	if abs(joypad_look.y) > 0.15:
		rotation.y -= joypad_look.y * joypad_sensitivity * base_joypad_sensitivity
	if abs(joypad_look.x) > 0.15:
		$Head.rotation.x -= joypad_look.x * joypad_sensitivity * base_joypad_sensitivity
		$Head.rotation.x = clamp($Head.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	# Friction
	var friction = ground_friction if is_on_floor() else air_friction
	
	velocity.x *= friction
	velocity.z *= friction
	
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity

	# Input
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	# Move
	if direction:
		var acceleration = ground_acceleration if is_on_floor() else air_acceleration
		
		velocity.x += direction.x * acceleration
		velocity.z += direction.z * acceleration
	
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity * base_mouse_sensitivity
		$Head.rotation.x -= event.relative.y * mouse_sensitivity * base_mouse_sensitivity
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	elif event is InputEventJoypadMotion:
		if event.axis == 2:
			joypad_look.y = event.axis_value
		elif event.axis == 3:
			joypad_look.x = event.axis_value
