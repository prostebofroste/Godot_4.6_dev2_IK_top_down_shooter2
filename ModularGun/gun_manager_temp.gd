# player_controller.gd
extends Node

@export var gun: Node3D # Podepnij ModularGun

# Przeciągnij tutaj stworzone Resources z FileSystemu
@export var shotgun_barrel_res: Resource
@export var antigrav_mag_res: Resource
@export var sniper_scope_res: Resource

func _input(event):
	if event.is_action_pressed("left_click"):
		# Gracz zakłada lufę shotguna
		gun.equip_mod(shotgun_barrel_res)
		
	if event.is_action_pressed("right_click"):
		# Gracz zakłada magazynek sci-fi
		gun.equip_mod(antigrav_mag_res)
	if event.is_action_pressed("ui_accept"): # Spacja/Enter
		# Strzał
		gun.shoot()
