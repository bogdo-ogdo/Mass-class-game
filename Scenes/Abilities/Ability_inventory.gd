extends Resource
class_name Ability_Inventory

signal updated

@export var abilities : Array[Ability]

var new_ability : bool

func insert(ability : Ability):
	new_ability = true
	for i in range(abilities.size()):
		if abilities[i] == ability:
			abilities[i].quantity += 1
			new_ability = false
	if new_ability == true:
		abilities.push_back(ability)
	updated.emit()
