class_name AudioManager
extends Node

@onready var _background_sound: AudioStreamPlayer = %BackgroundSound

@onready var _sfx_player: AudioStreamPlayer = %SFXPlayer
@onready var _sfx_playback: AudioStreamPlaybackPolyphonic = _sfx_player.get_stream_playback()

var newest_sfx_id: int

const _BACKGROUNDS: Dictionary[String, AudioStream] = {
	man = preload("uid://bj6m283i46yir"),
	celeste_start = preload("uid://cr2fk6bar7hgh"),
}

const _SOUNDS: Dictionary[String, AudioStream] = {
	jump = preload("uid://cf2tml7gdyii5"),
	charge = preload("uid://ceh34tgeeukyw"),
}

func play_background(sound_name: String):
	if _BACKGROUNDS[sound_name] != null:
		
		_background_sound.stream = _BACKGROUNDS[sound_name]
		_background_sound.play()


func _on_background_sound_finished(source: AudioStreamPlayer) -> void:
	source.play()


func stop_background() -> void:
	_background_sound.stop()


func clear_background() -> void:
	_background_sound.stream = null


func has_background() -> bool:
	return _background_sound.stream != null


func fade_background(start: float, end: float, duration: float = 1):
	_background_sound.volume_linear = start
	create_tween().tween_property(_background_sound, "volume_linear", end, duration)


func _real_play_sfx(stream: AudioStreamOggVorbis) -> void:
	newest_sfx_id = _sfx_playback.play_stream(stream)

func play_sfx(sfx_name: String):
	var sound_to_play: AudioStreamOggVorbis = _SOUNDS[sfx_name]
	
	if sound_to_play == null:
		print("No SFX to play! Insert it into the play_sfx() method.")
		return
	
	_real_play_sfx(sound_to_play)


func stop_sfx() -> void:
	if _sfx_playback.is_stream_playing(newest_sfx_id):
		_sfx_playback.stop_stream(newest_sfx_id)
