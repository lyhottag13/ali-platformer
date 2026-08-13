class_name AudioManager
extends Node

@onready var _background_sound: AudioStreamPlayer = %BackgroundSound
@onready var sfx_container: Node = %SFXContainer
var _audio_stream_players: Array[AudioStreamPlayer] = []

const _BACKGROUNDS: Dictionary[String, AudioStream] = {
	man = preload("uid://bj6m283i46yir"),
	celeste_start = preload("uid://cr2fk6bar7hgh"),
}

const _SOUNDS: Dictionary[String, AudioStream] = {
	jump = preload("uid://cf2tml7gdyii5"),
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


func print() -> void:
	print(_background_sound.stream)


func fade_background(start: float, end: float, duration: float = 1):
	_background_sound.volume_linear = start
	create_tween().tween_property(_background_sound, "volume_linear", end, duration)


func _real_play_sfx(stream: AudioStream) -> void:
	for sfx_player in _audio_stream_players:
		if not sfx_player.playing:
			sfx_player.stream = stream
			sfx_player.play()
			await sfx_player.finished
			return
	
	# Failsafe in case there aren't enough sfx_players
	print("Made a new SFX player!")
	var new_sfx_player = AudioStreamPlayer.new()
	sfx_container.add_child(new_sfx_player)
	new_sfx_player.stream = stream
	new_sfx_player.play()
	await new_sfx_player.finished
	_audio_stream_players.append(new_sfx_player)


func play_sfx(sfx_name: StringName):
	var sound_to_play: AudioStreamOggVorbis = _SOUNDS[sfx_name]
	
	if sound_to_play == null:
		print("No SFX to play! Insert it into the play_sfx() method.")
		return
	
	await _real_play_sfx(sound_to_play)
