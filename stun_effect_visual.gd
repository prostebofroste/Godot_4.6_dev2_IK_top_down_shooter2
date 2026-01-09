extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var sprite_3d_2: Sprite3D = $Sprite3D2
@onready var sprite_3d: Sprite3D = $Sprite3D

func _ready() -> void:
	sprite_3d_2.visible = false
	sprite_3d.visible = false
	gpu_particles_3d.emitting = false

func play():
	sprite_3d_2.visible = true
	sprite_3d.visible = true
	gpu_particles_3d.emitting = true	
	audio_stream_player_3d.play()
func stop():
	sprite_3d_2.visible = false
	sprite_3d.visible = false
	gpu_particles_3d.emitting = false
	audio_stream_player_3d.stop()
