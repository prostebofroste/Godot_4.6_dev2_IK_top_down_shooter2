extends StaticBody3D

@export var bullet_scene: PackedScene
@onready var barrel: Marker3D = $barrel
@onready var fire_rate: Timer = $FireRate
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var can_shoot := true
var can_melee := false
var _is_left_clicked := false
var _is_right_clicked := false
var _is_melee_clicked := false	
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	
	if event.is_action("spacebar"):
		_is_melee_clicked = true
	if event.is_action("right_click"):
		_is_right_clicked = true
	if event.is_action_released("right_click"):
		_is_right_clicked = false	
	if event.is_action_pressed("left_click"):
		_is_left_clicked = true
	if event.is_action_released("left_click"):
		_is_left_clicked = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	shoot()
	zoom()

func shoot():
	if _is_left_clicked and can_shoot:
		fire_rate.start()
		can_shoot = false
		audio_stream_player_3d.pitch_scale = randf_range(0.8,1)
		audio_stream_player_3d.play()
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = barrel.global_position
		bullet.global_rotation = barrel.global_rotation
		pass
func zoom():
	var t = create_tween()
	if _is_right_clicked:
		t.tween_property(Engine,"time_scale",0.5,0.1)
		t.tween_property(AudioServer, "playback_speed_scale",0.8,0.1)
	else:
		t.tween_property(Engine,"time_scale",1,0.1)
		t.tween_property(AudioServer, "playback_speed_scale",1,0.1)

func _on_fire_rate_timeout() -> void:
	can_shoot = true	
	pass # Replace with function body.
