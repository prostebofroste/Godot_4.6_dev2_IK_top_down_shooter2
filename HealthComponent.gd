extends Node
class_name health_component


signal died
signal health_changed



@export var max_health: float = 100.0
var current_health : float
func _ready() -> void:
	current_health = max_health
	
func damage(amount):
	current_health -= amount
	health_changed.emit(current_health)
	print("zadano", amount)
	if current_health < 0:
		current_health = 0
	if current_health == 0:
		print("obiekt ma zero hp, umiera")
		died.emit()
	pass

func heal():
	pass
	
