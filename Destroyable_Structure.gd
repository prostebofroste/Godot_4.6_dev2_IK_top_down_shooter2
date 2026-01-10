extends RigidBody3D

@export var hp: health_component
@export var explosion: Node3D 
@export var model: Node3D 
@export var knockback_strength: float = 100.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hp:
		hp.died.connect(_death)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _death():
	$CollisionShape3D.disabled = true
	model.visible = false
	explosion.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()
	pass

func apply_knockback(source_position: Vector3, amount):
	var direction = source_position.direction_to(global_position)
	direction.y = 0.0
	direction = direction.normalized()
	apply_central_impulse(direction * (knockback_strength + amount))
