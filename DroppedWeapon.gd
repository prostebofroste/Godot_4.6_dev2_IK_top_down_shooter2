extends RigidBody3D
class_name DroppedWeapon

@export var weapon_data: WeaponResource

func _ready():
	# Instancjonujemy model, żeby było widać co leży
	var model = weapon_data.weapon_model.instantiate()
	add_child(model)
