extends Node

var red_tween: Tween

var old_mouse_position: Vector2
@onready var crosshair: Sprite2D = %Crosshair
@onready var camera_2d: Camera2D = %Camera2D
@onready var halo: Panel = %Halo

@onready var level: Level = $World/Level
@onready var player: Player = $World/Player

func _ready() -> void:
	SoundManager.play_background("celeste_start")


func _input(event: InputEvent) -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skip"):
		if event is InputEventKey:
			match event.keycode:
				KEY_Z:
					player.position = level.get_cheat_position("forest")
				KEY_X:
					player.position = level.get_cheat_position("mountains")
				KEY_C:
					player.position = level.get_cheat_position("castle")
				KEY_V:
					player.position = level.get_cheat_position("summit")
				KEY_B:
					player.position = level.get_cheat_position("cabin")


func _on_level_change_camera(point: Vector2) -> void:
	camera_2d.position = point


func _on_level_leave() -> void:
	player.queue_free()
	await get_tree().create_timer(1).timeout
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href='https://lyhottag13.github.io/shop-'")


func _on_player_charging_started(crosshair_position: Vector2) -> void:
	crosshair.show()
	crosshair.position = crosshair_position
	halo.show()
	halo.size = Vector2(200, 200)
	halo.position = crosshair_position - halo.size / 2


func _on_player_charging_stopped() -> void:
	crosshair.hide()
	halo.hide()
