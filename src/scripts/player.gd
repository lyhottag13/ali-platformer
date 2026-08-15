class_name Player
extends CharacterBody2D

signal charging_started(crosshair_position: Vector2)
signal charging_stopped

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

const MAX_STRENGTH := 80
const STRENGTH_MULTIPLIER := 6
const WIND_SPEED = -5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#var old_mouse_position: Vector2

var red_tween: Tween

enum States {
	IDLE,
	RUNNING,
	CHARGING,
	JUMPING,
	REGULAR_JUMPING,
	FALLING,
	REGULAR_FALLING,
}

enum WindStates {
	NO_WIND,
	WIND,
}

var state: States = States.IDLE:
	set(new_state):
		var old_state: States = state
		
		match old_state:
			States.JUMPING:
				animated_sprite_2d.scale = Vector2(1, 1)
			States.CHARGING:
				SoundManager.stop_sfx()
				
				if red_tween.is_valid():
					red_tween.kill()
				
				modulate = Color.WHITE
				scale.y = 1
				scale.x = 1
		
		match new_state:
			States.IDLE:
				animated_sprite_2d.play("idling")
			States.RUNNING:
				animated_sprite_2d.play("running")
			States.JUMPING, States.REGULAR_JUMPING:
				SoundManager.play_sfx("jump")
				animated_sprite_2d.play("jumping")
			States.FALLING, States.REGULAR_FALLING:
				animated_sprite_2d.scale = Vector2.ONE
				animated_sprite_2d.play("falling")
			States.CHARGING:
				red_tween = create_tween()
				red_tween.tween_property(self, "modulate", Color.RED, 0.5)
				red_tween.parallel().tween_property(self, "scale:y", 0.8, 0.5)
				red_tween.parallel().tween_property(self, "scale:x", 1.2, 0.5)
				old_mouse_position = get_viewport().get_mouse_position()
				charging_started.emit(old_mouse_position)
				animated_sprite_2d.play("charging")
				SoundManager.play_sfx("charge")
		
		state = new_state

var wind_state: WindStates = WindStates.NO_WIND

var old_mouse_position: Vector2

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	match state:
		States.IDLE:
			if not is_on_floor():
				state = States.FALLING
			elif Input.is_action_pressed("jump"):
				state = States.REGULAR_JUMPING
				velocity.y = JUMP_VELOCITY
			elif direction:
				state = States.RUNNING
				velocity.x = direction * SPEED
			elif Input.is_action_just_pressed("real_jump"):
				state = States.CHARGING
			elif velocity.x != 0:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		
		States.RUNNING:
			if not is_on_floor():
				state = States.FALLING
			elif Input.is_action_just_pressed("real_jump"):
				state = States.CHARGING
			elif Input.is_action_pressed("jump"):
				state = States.REGULAR_JUMPING
				velocity.y = JUMP_VELOCITY
			elif direction:
				velocity.x = direction * SPEED
			else:
				state = States.IDLE
		
		States.CHARGING:
			velocity.x = 0
			
			var new_mouse_position = get_viewport().get_mouse_position()
			
			if new_mouse_position.x > old_mouse_position.x:
				animated_sprite_2d.flip_h = true
			elif new_mouse_position.x < old_mouse_position.x:
				animated_sprite_2d.flip_h = false
			
			if Input.is_action_just_released("real_jump"):
				state = States.JUMPING
				
				charging_stopped.emit()
				
				var difference: Vector2 = old_mouse_position - new_mouse_position
				
				if difference.length() > MAX_STRENGTH:
					difference = difference.normalized() * MAX_STRENGTH
				
				velocity = difference * STRENGTH_MULTIPLIER
		
		States.JUMPING:
			velocity += delta * get_gravity()
			if velocity.y > 0:
				state = States.FALLING
			else:
				animated_sprite_2d.scale.y = clamp(1 + abs(velocity.y * 0.002), 1, 1.2)
				animated_sprite_2d.scale.x = clamp(1 - abs(velocity.y * 0.001), 0.8, 1)
		
		States.REGULAR_JUMPING:
			velocity += delta * get_gravity()
			if velocity.y > 0:
				state = States.REGULAR_FALLING
			else:
				animated_sprite_2d.scale.y = clamp(1 + abs(velocity.y * 0.002), 1, 1.2)
				animated_sprite_2d.scale.x = clamp(1 - abs(velocity.y * 0.001), 0.8, 1)
			
			if direction:
				velocity.x = SPEED * direction
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		
		States.FALLING:
			velocity += delta * get_gravity()
			if is_on_floor():
				state = States.IDLE
		
		States.REGULAR_FALLING:
			velocity += delta * get_gravity()
			if is_on_floor():
				state = States.IDLE
			if direction:
				velocity.x = SPEED * direction
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if wind_state == WindStates.WIND and state != States.CHARGING:
		velocity.x += WIND_SPEED
	
	if velocity.x < 0:
		animated_sprite_2d.position.x = 3
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.position.x = -3
		animated_sprite_2d.flip_h = false
	
	move_and_slide()


func set_wind(enabled: bool):
	wind_state = WindStates.WIND if enabled else WindStates.NO_WIND
