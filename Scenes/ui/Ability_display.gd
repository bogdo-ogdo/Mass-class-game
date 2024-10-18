extends Control

@onready var ability_inventory : Ability_Inventory = preload("res://Scenes/Abilities/Ability_inventory.tres")
@onready var grid_container : GridContainer = $GridContainer
@export var ability_slot : PackedScene

var is_new : bool 
var first : bool = true
var ab_list = []

func update():
	for ability in ability_inventory.abilities:
		is_new = true
		for i in ab_list:
			if i == ability:
				is_new = false
		if is_new:
			var ab = ability_slot.instantiate()
			grid_container.add_child(ab)
			ab.update(ability)
			ab_list.push_back(ability)


func _on_pause_menu_opened():
	for child in grid_container.get_children():
		child.queue_free()
	ab_list = []
	call_deferred("update")


func _on_pause_menu_closed():
	pass
