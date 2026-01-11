# player_controller.gd
extends Node

@export var gun: Node3D # Podepnij ModularGun

# Przeciągnij tutaj stworzone Resources z FileSystemu
@export var shotgun_barrel_res: Resource
@export var antigrav_mag_res: Resource
@export var sniper_scope_res: Resource

func _input(event):
	if event.is_action_pressed("left_click"):
		gun.equip_mod(shotgun_barrel_res)
	if event.is_action_pressed("right_click"):
		gun.drop_mod(WeaponMod.SlotType.BARREL)
	if event.is_action_pressed("ui_accept"): 
		gun.shoot()
