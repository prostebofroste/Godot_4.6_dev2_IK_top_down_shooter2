extends Area3D
var SPEED = 20.0

@onready var timer: Timer = $Timer
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var explosion: Node3D = $explosion


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
		print("trafoiono: ", body)
		mesh_instance_3d.visible = false
		collision_shape_3d.disabled = true
		explosion.play()
		await get_tree().create_timer(2.0).timeout
		call_deferred("queue_free")
		



func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
