extends Node3D

@onready var debris: GPUParticles3D = $debris
@onready var fire: GPUParticles3D = $fire
@onready var smoke: GPUParticles3D = $smoke
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D



func play():
	debris.emitting = true
	fire.emitting = true
	smoke.emitting = true
	audio_stream_player_3d.play()
	await get_tree().create_timer(2).timeout
	queue_free()
