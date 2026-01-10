# weapon_mod.gd
class_name WeaponMod extends Resource

# Typy slotów zdefiniowane raz na sztywno
enum SlotType { BARREL, MAGAZINE, SCOPE, STOCK, GRIP }

@export_category("Visuals & UI")
@export var mod_name: String = "Nowy Moduł"
@export var slot_type: SlotType
@export var icon: Texture2D
# Model 3D, który doczepimy do broni (np. plik .glb lub .tscn z lufą)
@export var visual_scene: PackedScene 

@export_category("Stat Overrides")
# Proste statystyki, które zmieniają się automatycznie
@export var damage_multiplier: float = 1.0
@export var spread_add: float = 0.0

# --- MAGIA SYNERGII ---
# Funkcja wirtualna. Nadpisujesz ją tylko wtedy, gdy chcesz zrobić coś szalonego (np. Isaac style).
# 'stats' to słownik, który przelatuje przez wszystkie moduły.
func apply_synergy(stats: Dictionary) -> void:
	# Domyślnie aplikuje tylko proste mnożniki
	stats.damage *= damage_multiplier
	stats.spread += spread_add
