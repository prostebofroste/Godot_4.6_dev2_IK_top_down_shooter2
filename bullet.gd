extends Area3D


@onready var timer: Timer = $Timer
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var blood_hit_effect: Node3D = $BloodHitEffect

@export var push_power: float = 6
@export var SPEED = 20.0
@export var damage: float = 25.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func _process(_delta: float) -> void:
	
	position -=  transform.basis.z * SPEED * _delta
	pass

func _on_body_entered(body: Node3D) -> void:
	if body:
		var hp_component = body.get_node_or_null("HealthComponent")
		if hp_component:
			hp_component.damage(damage)
		if body.is_in_group("Kickable"):
				if body.has_method("apply_knockback"):
					body.apply_knockback(global_position,push_power)
		print("trafoiono: ", body)
		if body.is_in_group("Enemy"):
			blood_hit_effect.play()
			if body.is_in_group("Kickable"):
				body.velocity = Vector3.ZERO
		mesh_instance_3d.visible = false
		collision_shape_3d.disabled = true
		await get_tree().create_timer(2.0).timeout
		call_deferred("queue_free")





func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
