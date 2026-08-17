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
@onready var snow_particles: Array[CPUParticles2D]
@onready var snow_particles_container: Node = $SnowParticlesContainer

@onready var tutorial_text: Label = $TutorialText

var wind_state: WindState
const SNOW_MAX_SPEED := 300.0
var snow_speed: float = 0
var should_send_wind := false
var is_wind_changing := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const MAX_HEIGHT := 3100.0
	
	for i in range(ceili(MAX_HEIGHT / 180)):
		var new_camera_area: Area2D = CAMERA_AREA.instantiate()
		new_camera_area.body_entered.connect(_on_area_2d_body_entered, CONNECT_APPEND_SOURCE_OBJECT)
		new_camera_area.position = Vector2(160, -184 * i + 90)
		add_child(new_camera_area)
	
	var eliminate_text = func():
		create_tween().tween_property(tutorial_text, "modulate", Color.TRANSPARENT, 1)
	
	get_tree().create_timer(5).timeout.connect(eliminate_text)
	
	for snow_particle in snow_particles_container.get_children():
		if snow_particle is CPUParticles2D:
			snow_particles.append(snow_particle)


func _process(delta: float) -> void:
	_handle_snow(delta)
	
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
	should_send_wind = true

func _on_wind_area_body_exited(body: Player) -> void:
	body.set_wind(0)
	should_send_wind = false

func _on_snow_timer_timeout() -> void:
	wind_state = WindState.LEFT if wind_state == WindState.RIGHT else WindState.RIGHT
	is_wind_changing = true


func _handle_snow(delta: float) -> void:
	if is_wind_changing:
		var lerped = lerpf(snow_speed, SNOW_MAX_SPEED if wind_state == WindState.RIGHT else -SNOW_MAX_SPEED, delta)
		if lerped == snow_speed:
			is_wind_changing = false
		else:
			snow_speed = lerped
			if should_send_wind:
				wind_area.get_overlapping_bodies().get(0).set_wind(snow_speed / 60.0)
	
	for snow_particle in snow_particles:
		snow_particle.position.x += snow_speed * delta
		snow_particle.position.x = -160.0 if snow_particle.position.x > 480.0 else snow_particle.position.x
		snow_particle.position.x = 480.0 if snow_particle.position.x < -160.0 else snow_particle.position.x
