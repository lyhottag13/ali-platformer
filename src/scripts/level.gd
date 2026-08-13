extends Node2D

signal change_camera(point: Vector2)
signal leave

const CAMERA_AREA = preload("uid://dputjmki8drhv")

@onready var area_container: Node = $AreaContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const MAX_HEIGHT := 3100.0
	
	for i in range(ceili(MAX_HEIGHT / 180)):
		var new_camera_area: Area2D = CAMERA_AREA.instantiate()
		new_camera_area.body_entered.connect(_on_area_2d_body_entered, CONNECT_APPEND_SOURCE_OBJECT)
		new_camera_area.position = Vector2(160, -184 * i + 90)
		add_child(new_camera_area)


func _on_area_2d_body_entered(_body: Node2D, area: Area2D) -> void:
	change_camera.emit(area.position)


func _on_door_body_entered(body: Node2D) -> void:
	print_debug(body)
	leave.emit()


func _on_final_area_body_entered(body: Node2D) -> void:
	SoundManager.play_background("man")


func _on_final_area_body_exited(body: Node2D) -> void:
	SoundManager.clear_background()
