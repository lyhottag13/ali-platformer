extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const AIR_SPEED = 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var old_mouse_position: Vector2
var current_direction: Vector2

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if velocity.y < 0:
			animated_sprite_2d.play("jump_up")
			animated_sprite_2d.scale.y = clamp(1 + abs(velocity.y * 0.002), 1, 1.2)
			animated_sprite_2d.scale.x = clamp(1 - abs(velocity.y * 0.001), 0.8, 1)
		elif velocity.y > 0:
			animated_sprite_2d.play("jump_down")
			animated_sprite_2d.scale = Vector2(1, 1)
	
	else:
		if velocity.x < 0:
			animated_sprite_2d.play("running")
			animated_sprite_2d.flip_h = true
		elif velocity.x > 0:
			animated_sprite_2d.play("running")
			animated_sprite_2d.flip_h = false
		elif velocity.x == 0:
			animated_sprite_2d.play("idling")
	
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
