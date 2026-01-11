# comparison_ui.gd
extends CanvasLayer

@onready var panel = $PanelContainer
@onready var current_stats_label = $PanelContainer/HBoxContainer/CurrentItemInfo/StatsLabel
@onready var new_stats_label = $PanelContainer/HBoxContainer/NewItemInfo/Statslabel

func _ready():
	hide_tooltip()

func show_comparison(new_mod: WeaponMod, current_mod: WeaponMod):
	panel.visible = true
	
	# 1. Pokaż statystyki tego co leży na ziemi
	var new_text = "[b]%s[/b]\n" % new_mod.mod_name
	new_text += "Dmg x%.1f\n" % new_mod.damage_multiplier
	new_text += "Spread: %.1f" % new_mod.spread_add
	new_stats_label.text = new_text
	
	# 2. Pokaż statystyki tego co masz (jeśli masz)
	if current_mod:
		var curr_text = "[b]%s[/b]\n" % current_mod.mod_name
		curr_text += "Dmg x%.1f\n" % current_mod.damage_multiplier
		curr_text += "Spread: %.1f" % current_mod.spread_add
		current_stats_label.text = curr_text
		
		# Kolorowanie (opcjonalne bajery Diablo-style)
		if new_mod.damage_multiplier > current_mod.damage_multiplier:
			new_stats_label.modulate = Color.GREEN
		else:
			new_stats_label.modulate = Color.WHITE
	else:
		current_stats_label.text = "[ Brak ]"
		new_stats_label.modulate = Color.GREEN # Zawsze lepsze niż nic

func hide_tooltip():
	panel.visible = false
