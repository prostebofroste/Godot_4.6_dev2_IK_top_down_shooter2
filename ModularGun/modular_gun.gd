# modular_gun.gd
extends Node3D

# --- KONFIGURACJA ---
# Przypisz tutaj swoje Markery3D w edytorze
@export_group("Mount Points") # To zrobi ładną nagłówkową sekcję
@export var barrel_point: Marker3D
@export var magazine_point: Marker3D
@export var scope_point: Marker3D
@export var stock_point: Marker3D
@export var grip_point: Marker3D

# Tutaj trzymamy aktualnie założone Resource'y (Data)
var mount_points: Dictionary = {}
var equipped_mods: Dictionary = {} 
# Tutaj trzymamy wizualne obiekty 3D (żeby móc je usunąć przy zmianie)
var visual_instances: Dictionary = {}

func _ready():
	# 1. Mapujemy zmienne z Inspektora do Słownika
	mount_points[WeaponMod.SlotType.BARREL] = barrel_point
	mount_points[WeaponMod.SlotType.MAGAZINE] = magazine_point
	mount_points[WeaponMod.SlotType.SCOPE] = scope_point
	mount_points[WeaponMod.SlotType.STOCK] = stock_point
	mount_points[WeaponMod.SlotType.GRIP] = grip_point
	print("--- SYSTEM GOTOWY ---")

# --- CORE SYSTEMU (To montuje część) ---
func equip_mod(mod: WeaponMod):
	if mod == null: return
	
	var slot = mod.slot_type
	
	# 1. Posprzątaj stary model jeśli był
	if visual_instances.has(slot):
		visual_instances[slot].queue_free()
		
	# 2. Zapisz dane
	equipped_mods[slot] = mod
	
	# 3. Zspawnuj nowy model 3D
	if mod.visual_scene and mount_points.has(slot):
		var parent_marker = mount_points[slot]
		var new_visual = mod.visual_scene.instantiate()
		parent_marker.add_child(new_visual)
		# Reset transformacji żeby pasowało idealnie do markera
		new_visual.transform = Transform3D.IDENTITY
		visual_instances[slot] = new_visual
		
	print("Zamontowano: %s w slocie %s" % [mod.mod_name, WeaponMod.SlotType.keys()[slot]])
	print_current_loadout() # Odśwież UI (print)

# --- SHOOTING PIPELINE (Tu dzieje się magia Isaaca) ---
func shoot():
	# 1. Czysta kartka (Default Stats)
	var stats = {
		"damage": 10.0,
		"spread": 0.0,
		"projectile_count": 1,
		"gravity_scale": 1.0,
		"is_homing": false,
		"bullet_color": Color.WHITE,
		"sound_override": "pew_standard"
	}
	
	# 2. Pętla modyfikacji (Chain of Responsibility)
	for slot in equipped_mods:
		var mod = equipped_mods[slot]
		mod.apply_synergy(stats)
		
	# 3. Wynik
	spawn_bullet(stats)

func spawn_bullet(final_stats: Dictionary):
	# Tutaj byłby kod spawnowania pocisku fizycznego
	print("\n>>> STRZAŁ! <<<")
	print("Dmg: %s | Ilość kul: %s | Kolor: %s" % [final_stats.damage, final_stats.projectile_count, final_stats.bullet_color])
	if final_stats.is_homing: print("Efekt: SAMONAPROWADZANIE")
	if final_stats.gravity_scale == 0: print("Efekt: ANTYGRAWITACJA")
	print("-----------------")

# --- PROSTE TEXT UI (Dla debugu/inventory) ---
func print_current_loadout():
	print("\n=== TWOJE WYPOSAŻENIE ===")
	if equipped_mods.is_empty():
		print("[ Pusto ]")
	else:
		for slot in equipped_mods:
			var slot_name = WeaponMod.SlotType.keys()[slot]
			var mod_name = equipped_mods[slot].mod_name
			print("[%s]: %s" % [slot_name, mod_name])
	print("=========================\n")
