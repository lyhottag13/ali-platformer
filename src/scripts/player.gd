extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const AIR_SPEED = 0

var old_mouse_position: Vector2

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction and is_on_floor():
		velocity.x = direction * SPEED
	elif is_on_floor() and velocity.y == 0:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
