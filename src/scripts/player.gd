extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const AIR_SPEED = 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var tail_sprite: Sprite2D = $TailSprite
var old_mouse_position: Vector2
var current_direction: Vector2

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if velocity.y < 0:
			tail_sprite.offset = Vector2(-11, 4)
			animated_sprite_2d.play("jump_up")
			animated_sprite_2d.scale.y = clamp(1 + abs(velocity.y * 0.002), 1, 1.2)
			animated_sprite_2d.scale.x = clamp(1 - abs(velocity.y * 0.001), 0.8, 1)
			tail_sprite.flip_v = false
		elif velocity.y > 0:
			tail_sprite.offset = Vector2(-11, -3)
			animated_sprite_2d.play("jump_down")
			animated_sprite_2d.scale = Vector2(1, 1)
			tail_sprite.flip_v = true
		
		tail_sprite.rotation = 0
		
		if velocity.x > 0:
			current_direction = Vector2.RIGHT
			tail_sprite.scale = Vector2(1, 1)
		elif velocity.x < 0:
			current_direction = Vector2.LEFT
			tail_sprite.scale = Vector2(-1, 1)
		
	else:
		animated_sprite_2d.play("idling")
		
		tail_sprite.flip_v = false
		tail_sprite.rotation_degrees = 90
		tail_sprite.offset = Vector2(-3, 1)
		if velocity.x < 0:
			current_direction = Vector2.LEFT
			animated_sprite_2d.flip_h = true
			tail_sprite.scale = Vector2(1, -1)
		elif velocity.x > 0:
			current_direction = Vector2.RIGHT
			animated_sprite_2d.flip_h = false
			tail_sprite.scale = Vector2(1, 1)
		elif velocity.x == 0:
			if current_direction == Vector2.LEFT:
				tail_sprite.scale = Vector2(1, -1)
	
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
