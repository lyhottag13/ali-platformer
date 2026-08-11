extends Area2D

@onready var marker_2d: Marker2D = $Marker2D

func get_marker() -> Vector2:
	return marker_2d.position
