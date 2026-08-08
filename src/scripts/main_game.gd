extends Node

@onready var player: CharacterBody2D = $World/Player

var red_tween: Tween
var is_charging := false

var old_mouse_position: Vector2
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and player.is_on_floor():
			is_charging = true
			player.set_physics_process(false)
			old_mouse_position = get_viewport().get_mouse_position()
			red_tween = create_tween()
			red_tween.tween_property(player, "modulate", Color.RED, 0.5)
			red_tween.parallel().tween_property(player, "scale:y", 0.8, 0.5)
			red_tween.parallel().tween_property(player, "scale:x", 1.2, 0.5)
		elif not event.pressed and player.is_on_floor() and is_charging:
			red_tween.kill()
			player.modulate = Color.WHITE
			player.scale.y = 1
			player.scale.x = 1
			var new_mouse_position := get_viewport().get_mouse_position()
			var difference := old_mouse_position - new_mouse_position
			player.set_physics_process(true)
			print(difference)
			player.velocity = difference * 5
			is_charging = false
