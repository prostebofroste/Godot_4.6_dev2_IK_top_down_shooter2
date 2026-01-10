# res://mods/antigrav_mag.gd
extends WeaponMod

func apply_synergy(stats: Dictionary) -> void:
	super.apply_synergy(stats)
	
	# Zmieniamy fizykę pocisku
	stats.gravity_scale = 0.0
	stats.is_homing = true # Pociski samonaprowadzające
	stats.bullet_color = Color.PURPLE
