extends Node

@onready var player: CharacterBody2D = $World/Player

const MAX_STRENGTH := 80
const STRENGTH_MULTIPLIER := 6

var red_tween: Tween
var is_charging := false

var old_mouse_position: Vector2
@onready var crosshair: Sprite2D = %Crosshair
@onready var camera_2d: Camera2D = $Camera2D
@onready var halo: Panel = $CanvasLayer/Halo

func _input(event: InputEvent) -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.pressed and player.is_on_floor():
			is_charging = true
			player.set_physics_process(false)
			old_mouse_position = get_viewport().get_mouse_position()
			crosshair.show()
			crosshair.position = old_mouse_position
			red_tween = create_tween()
			red_tween.tween_property(player, "modulate", Color.RED, 0.5)
			red_tween.parallel().tween_property(player, "scale:y", 0.8, 0.5)
			red_tween.parallel().tween_property(player, "scale:x", 1.2, 0.5)
			
			halo.show()
			halo.size = Vector2(MAX_STRENGTH * 2, MAX_STRENGTH * 2)
			halo.position = old_mouse_position - halo.size / 2
		elif not event.pressed and player.is_on_floor() and is_charging:
			crosshair.hide()
			halo.hide()
			red_tween.kill()
			player.modulate = Color.WHITE
			player.scale.y = 1
			player.scale.x = 1
			
			var new_mouse_position := get_viewport().get_mouse_position()
			var difference := old_mouse_position - new_mouse_position
			if difference.length() > MAX_STRENGTH:
				difference = difference.normalized() * MAX_STRENGTH
			player.velocity = difference * STRENGTH_MULTIPLIER
			player.set_physics_process(true)
			is_charging = false
	elif event.is_action_pressed("skip"):
		player.position = Vector2(200, -1850)

func _on_level_change_camera(point: Vector2) -> void:
	camera_2d.position = point


func _on_level_leave() -> void:
	player.queue_free()
	await get_tree().create_timer(1).timeout
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href='https://lyhottag13.github.io/shop-'")
