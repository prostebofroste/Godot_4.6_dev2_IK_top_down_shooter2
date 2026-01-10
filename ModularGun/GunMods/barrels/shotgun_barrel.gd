# res://mods/shotgun_barrel.gd
extends WeaponMod

func apply_synergy(stats: Dictionary) -> void:
	# Najpierw standardowe staty (zmienione w inspektorze)
	super.apply_synergy(stats)
	
	# LOGIKA SPECJALNA:
	stats.projectile_count += 4       # Więcej pocisków
