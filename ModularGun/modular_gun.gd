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

func equip_mod(mod: WeaponMod):
	if mod == null: return
	var slot = mod.slot_type
	
	# 1. Jeśli coś już jest w tym slocie -> WYRZUĆ TO NA ZIEMIĘ
	if equipped_mods.has(slot):
		drop_mod(slot)

	# 2. Zapisz dane
	equipped_mods[slot] = mod
	
	# 3. Zspawnuj obiekt (lub weź istniejący, ale dla uproszczenia instancjonujemy z Resource)
	if mod.visual_scene and mount_points.has(slot):
		var part_instance = mod.visual_scene.instantiate() as RigidBody3D
		
		# --- KLUCZOWE: PRZYSPAWANIE DO BRONI ---
		mount_points[slot].add_child(part_instance)
		
		# Wyłączamy fizykę całkowicie
		part_instance.freeze = true
		part_instance.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		
		# Wyłączamy kolizje (żeby nie spychało gracza!)
		# Zakładam, że warstwa 1 to świat, wyłączamy to.
		
		# Reset pozycji do zera (żeby pasowało do markera)
		part_instance.transform = Transform3D.IDENTITY
		
		visual_instances[slot] = part_instance
		print("Założono: ", mod.mod_name)


# --- WYRZUCANIE (Odczep i włącz fizykę) ---
func drop_mod(slot: WeaponMod.SlotType):
	if not visual_instances.has(slot): return
	
	var part_instance = visual_instances[slot] # To jest nasz RigidBody3D
	
	# 1. Odczepiamy od broni (Reparenting)
	# Musimy zmienić rodzica na "Świat" (czyli np. obecną scenę gry)
	part_instance.reparent(get_tree().current_scene)
	
	# 2. Ustawiamy pozycję startową rzutu
	# (Dzięki reparent zachowa pozycję w świecie, ale warto go lekko odsunąć)
	part_instance.global_position = global_position + (global_transform.basis.z * -1.0) # 1 metr przed bronią
	
	# --- KLUCZOWE: WŁĄCZENIE FIZYKI ---
	part_instance.freeze = false
	
	# Przywracamy kolizje (żeby odbijał się od podłogi)

	
	# Lekki rzut do przodu
	part_instance.linear_velocity = Vector3.ZERO
	part_instance.apply_impulse(global_transform.basis.z * -5.0) # Wyrzut przed siebie
	
	# 3. Czyścimy pamięć broni
	visual_instances.erase(slot)
	equipped_mods.erase(slot)
	
	print("Wyrzucono mod na ziemię (fizyka on)")

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
