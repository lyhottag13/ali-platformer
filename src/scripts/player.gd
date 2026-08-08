extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const AIR_SPEED = 1

var old_mouse_position: Vector2
var can_move := true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		can_move = false
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction and is_on_floor():
		can_move = true
		velocity.x = direction * SPEED
	elif is_on_floor():
		can_move = true
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, AIR_SPEED)

	move_and_slide()


func set_move(enabled: bool):
	can_move = enabled
