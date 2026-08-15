class_name Player
extends CharacterBody2D

signal charging_started(crosshair_position: Vector2)
signal charging_stopped

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const AIR_SPEED = 0

const MAX_STRENGTH := 80
const STRENGTH_MULTIPLIER := 6

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#var old_mouse_position: Vector2

var red_tween: Tween

enum STATE {
	IDLE,
	RUNNING,
	CHARGING,
	JUMPING,
	REGULAR_JUMPING,
	FALLING,
	REGULAR_FALLING,
}

var state: STATE = STATE.IDLE:
	set(new_state):
		var old_state: STATE = state
		match old_state:
			STATE.JUMPING:
				animated_sprite_2d.scale = Vector2(1, 1)
		
		match new_state:
			STATE.IDLE:
				animated_sprite_2d.play("idling")
			STATE.RUNNING:
				animated_sprite_2d.play("running")
			STATE.JUMPING, STATE.REGULAR_JUMPING:
				animated_sprite_2d.play("jumping")
			STATE.FALLING, STATE.REGULAR_FALLING:
				animated_sprite_2d.play("falling")
			STATE.CHARGING:
				old_mouse_position = get_viewport().get_mouse_position()
				charging_started.emit(old_mouse_position)
				animated_sprite_2d.play("charging")
		state = new_state


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("real_jump") and state in [STATE.IDLE, STATE.RUNNING]:
		
		red_tween = create_tween()
		red_tween.tween_property(self, "modulate", Color.RED, 0.5)
		red_tween.parallel().tween_property(self, "scale:y", 0.8, 0.5)
		red_tween.parallel().tween_property(self, "scale:x", 1.2, 0.5)
		
	elif event.is_action_released("real_jump") and state == STATE.CHARGING:
		
		SoundManager.play_sfx("jump")
		red_tween.kill()
		modulate = Color.WHITE
		scale.y = 1
		scale.x = 1
		
	elif event.is_action_pressed("jump") and state in [STATE.IDLE, STATE.RUNNING]:
		state = STATE.REGULAR_JUMPING
		velocity.y = JUMP_VELOCITY

var old_mouse_position: Vector2

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	match state:
		STATE.IDLE:
			if Input.is_action_just_pressed("jump"):
				state = STATE.JUMPING
				velocity.y = JUMP_VELOCITY
			elif not is_on_floor():
				state = STATE.FALLING
			elif direction:
				state = STATE.RUNNING
				velocity.x = direction * SPEED
			elif velocity.x != 0:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			elif Input.is_action_just_pressed("real_jump"):
				state = STATE.CHARGING
		
		STATE.RUNNING:
			if not is_on_floor():
				state = STATE.FALLING
			elif Input.is_action_just_pressed("real_jump"):
				state = STATE.CHARGING
			elif Input.is_action_pressed("jump"):
				state = STATE.JUMPING
				velocity.y = JUMP_VELOCITY
			elif direction:
				velocity.x = direction * SPEED
			else:
				state = STATE.IDLE
		
		STATE.CHARGING:
			velocity.x = 0
			
			var new_mouse_position = get_viewport().get_mouse_position()
			
			if new_mouse_position.x > old_mouse_position.x:
				animated_sprite_2d.flip_h = true
			elif new_mouse_position.x < old_mouse_position.x:
				animated_sprite_2d.flip_h = false
			
			if Input.is_action_just_released("real_jump"):
				state = STATE.JUMPING
				
				charging_stopped.emit()
				
				var difference: Vector2 = old_mouse_position - new_mouse_position
				
				if difference.length() > MAX_STRENGTH:
					difference = difference.normalized() * MAX_STRENGTH
				
				velocity = difference * STRENGTH_MULTIPLIER
		
		STATE.JUMPING:
			velocity += delta * get_gravity()
			if velocity.y > 0:
				state = STATE.FALLING
			else:
				animated_sprite_2d.scale.y = clamp(1 + abs(velocity.y * 0.002), 1, 1.2)
				animated_sprite_2d.scale.x = clamp(1 - abs(velocity.y * 0.001), 0.8, 1)
		
		STATE.REGULAR_JUMPING:
			velocity += delta * get_gravity()
			if velocity.y > 0:
				state = STATE.REGULAR_FALLING
			else:
				animated_sprite_2d.scale.y = clamp(1 + abs(velocity.y * 0.002), 1, 1.2)
				animated_sprite_2d.scale.x = clamp(1 - abs(velocity.y * 0.001), 0.8, 1)
			
			if direction:
				velocity.x = SPEED * direction
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		
		STATE.FALLING:
			velocity += delta * get_gravity()
			if is_on_floor():
				state = STATE.IDLE
		
		STATE.REGULAR_FALLING:
			velocity += delta * get_gravity()
			if is_on_floor():
				state = STATE.IDLE
			if direction:
				velocity.x = SPEED * direction
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
	
	move_and_slide()
