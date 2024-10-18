extends Node

@export var initial_weapon : weapon_type

var current_weapon : weapon_type
var weapons : Dictionary = {}


func _ready():
	for child in get_children():
		if child is weapon_type:
			weapons[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			
	if initial_weapon:
		initial_weapon.Enter()
		current_weapon = initial_weapon


func _process(delta):
	if current_weapon:
		current_weapon.Update(delta)


func on_child_transition(_weapon, new_weapon_name):
	if weapon_type != current_weapon:
		return
	
	var new_weapon = weapons.get(new_weapon_name.to_lower())
	if !new_weapon:
		return
	
	if current_weapon:
		current_weapon.Exit()
	
	new_weapon.Enter()
	
	current_weapon = new_weapon
