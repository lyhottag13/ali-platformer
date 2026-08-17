class_name Level
extends Node2D

signal change_camera(point: Vector2)
signal leave

enum WindState {
	LEFT,
	RIGHT,
}

const CAMERA_AREA = preload("uid://dputjmki8drhv")
const WIND_SPEED := 5

@onready var area_container: Node = $AreaContainer

@onready var forest_marker: Marker2D = $CheatMarkers/ForestMarker
@onready var mountains_marker: Marker2D = $CheatMarkers/MountainsMarker
@onready var castle_marker: Marker2D = $CheatMarkers/CastleMarker
@onready var summit_marker: Marker2D = $CheatMarkers/SummitMarker
@onready var cabin_marker: Marker2D = $CheatMarkers/CabinMarker

@onready var snow_timer: Timer = $SnowTimer
@onready var wind_area: Area2D = $WindArea
@onready var snow_mask: Polygon2D = $SnowMask

var wind_state: WindState

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


func _on_final_area_body_entered(_body: Node2D) -> void:
	SoundManager.play_background("man")


func _on_final_area_body_exited(_body: Node2D) -> void:
	SoundManager.clear_background()


func get_cheat_position(position_name: String) -> Vector2:
	match position_name:
		"forest":
			return forest_marker.position
		"mountains":
			return mountains_marker.position
		"castle":
			return castle_marker.position	
		"summit":
			return summit_marker.position
		"cabin":
			return cabin_marker.position
		_:
			return forest_marker.position


func _on_wind_area_body_entered(body: Player) -> void:
	body.set_wind(WIND_SPEED if wind_state == WindState.RIGHT else -WIND_SPEED)


func _on_wind_area_body_exited(body: Player) -> void:
	body.set_wind(0)


func _on_snow_timer_timeout() -> void:
	wind_state = WindState.LEFT if wind_state == WindState.RIGHT else WindState.RIGHT
	
	var snow_particles := snow_mask.get_children()
	for snow_particle in snow_particles:
		if snow_particle is CPUParticles2D:
			snow_particle.position.x = -8 if wind_state == WindState.RIGHT else 326 
			snow_particle.direction.x = 1 if wind_state == WindState.RIGHT else -1  
	
	print(wind_state)
	var overlapping_bodies = wind_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body is Player:
			body.set_wind(WIND_SPEED if wind_state == WindState.RIGHT else -WIND_SPEED)
