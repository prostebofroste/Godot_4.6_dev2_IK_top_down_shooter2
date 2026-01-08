extends RigidBody3D

var knockback_strength = 15.0 

func _ready():
	linear_damp = 1.0  # Im wyższa wartość, tym szybciej obiekt wyhamuje do zera
	angular_damp = 1.0 # Wyhamowanie obrotów



func apply_knockback(source_position: Vector3):
	var direction = source_position.direction_to(global_position)
	direction.y = 0.5 
	direction = direction.normalized()
	apply_central_impulse(direction * knockback_strength)
