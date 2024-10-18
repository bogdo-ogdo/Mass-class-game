extends Panel

@onready var ability_inventory : Ability_Inventory = preload("res://Scenes/Abilities/Ability_inventory.tres")
@onready var description : RichTextLabel = $Description
@onready var ability_icon : Sprite2D = $ability_icon
@onready var price_label : Label = $Buy_button/Price
@onready var ability_name : Label = $Name

var player : CharacterBody2D
var can_buy : bool
var current_ability : Ability
var price : int

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func load_item(ability : Ability):
	price_label.self_modulate = Color(1,1,1)
	current_ability = ability
	visible = true
	can_buy = true
	ability_icon.texture = ability.texture
	ability_name.text = ability.ability_name
	description.text = ability.description
	price = int(randf_range(.85,1.15)*ability.cost)
	price_label.text = str(price)
	if player.gold < price:
		price_label.self_modulate = Color(0.749, 0, 0.059)
	else:
		price_label.self_modulate = Color(1,1,1)
	


func _on_buy_button_pressed():
	if player.gold >= price:
		player.gold -= price
		visible = false
		can_buy = false
		ability_inventory.abilities.push_front(current_ability)
		current_ability.quantity += 1
		if current_ability.unique:
			get_parent().unavalable_abilities.push_back(current_ability)
			
		get_parent().update_money()
	
