extends Node3D

@onready var debris: GPUParticles3D = $debris
@onready var fire: GPUParticles3D = $fire
@onready var smoke: GPUParticles3D = $smoke
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var anim_play: AnimationPlayer = $AnimationPlayer
@onready var dmg_area: Area3D = $dmg_area
@export var explosion_dmg: float 
@export var explosion_power: float = 20.0

func play():
	anim_play.play("radius_dmg")
	debris.emitting = true
	fire.emitting = true
	smoke.emitting = true
	audio_stream_player_3d.play()


func _on_dmg_area_body_entered(body: Node3D) -> void:
	print("target jest")
	if body.has_node("HealthComponent"):
		body.hp.damage(explosion_dmg)
		pass # Replace with function body.
	if body.is_in_group("Kickable"):
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position, explosion_power)
