# world_mod.gd
class_name WorldMod extends RigidBody3D

# --- TO JEDYNA RZECZ DO USTAWIENIA W INSPEKTORZE ---
@export var mod_resource: WeaponMod

func _ready():
	# Automatycznie dodajemy do grupy, żebyś nie musiał pamiętać
	add_to_group("GunMod")
	if mod_resource and mod_resource.visual_scene and has_node("Visual"):
		# Tu można by dodać logikę auto-wizualizacji, ale na razie zostawmy prosto
		pass

# Helper do szybkiego pobierania danych
func get_data() -> WeaponMod:
	return mod_resource
