extends Control

signal shop_closed

@export var reroll_button : Button
@export var shop_item1 : Panel
@export var shop_item2 : Panel
@export var shop_item3 : Panel
@export var shop_item4 : Panel
@export var money : Label
@export var avalable_abilities : Array[Ability]

var current_avalable_abilities : Array[Ability]
var unavalable_abilities : Array[Ability]
var player : CharacterBody2D
var is_open : bool = false
var reroll_cost : int
var is_in : bool 
var item1 : Ability
var item2 : Ability
var item3 : Ability 
var item4 : Ability

var rare_chance : float = .2
var legendary_chance : float = 0.05
var juice_chance : float = 0.01


func _process(delta):
	if is_open && modulate.a < 1:
		modulate.a += .1
	elif !is_open && modulate.a > 0:
		modulate.a -= .05
	elif !is_open && modulate.a <= 0:
		visible = false

func open():
	modulate.a = 0
	visible = true
	is_open = true
	reroll_cost = 0
	get_tree().paused = true
	update_money()
	reset_shop()

func close():
	is_open = false
	get_tree().paused = false
	shop_closed.emit()
	player.update_abilities()
	player.health_bar.value = player.max_health
	player.current_health = player.max_health


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	reset()



func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false:
				current_avalable_abilities.push_back(load("res://Scenes/Abilities/Ability/" + file_name))
			file_name = dir.get_next()


func reroll_shop():
	if reroll_cost <= player.gold:
		player.gold -= reroll_cost
		reroll_cost += 5
		reroll_items()
		reroll_button.text = "Reroll: " + str(reroll_cost)
		update_money()


func reset_shop():
	reroll_button.disabled = false
	is_in = true
	reroll_items()
	reroll_button.text = "Reroll: " + str(reroll_cost)
	update_money()

func reroll_items():
	is_in = true
	while is_in:
		item1 = get_random_item()
		is_in = false
		for i in unavalable_abilities:
			if item1 == i:
				is_in = true
	shop_item1.load_item(item1)
	item2 = get_random_item()
	is_in = true
	
	while item2 == item1 or is_in:
		item2 = get_random_item()
		is_in = false
		for i in unavalable_abilities:
			if item2 == i:
				is_in = true
	shop_item2.load_item(item2)
	item3 =  get_random_item()
	is_in = true
	
	while item3 == item1 or item3 == item2 or is_in:
		item3 = get_random_item()
		is_in = false
		for i in unavalable_abilities:
			if item3 == i:
				is_in = true
	shop_item3.load_item(item3)
	item4 =  get_random_item()
	is_in = true
	
	while item4 == item1 or item4 == item2 or item4 == item3 or is_in:
		item4 = get_random_item()
		is_in = false
		for i in unavalable_abilities:
			if item4 == i:
				is_in = true
	shop_item4.load_item(item4)


func get_random_item():
	var rng = randf()
	var item : Ability = current_avalable_abilities.pick_random()
	if rng < juice_chance:
		while item.rarity != 3:
			item = current_avalable_abilities.pick_random()
	elif rng < legendary_chance + juice_chance:
		# get legendary item
		while item.rarity != 2:
			item = current_avalable_abilities.pick_random()
	elif rng < legendary_chance + rare_chance:
		# get rare item
		while item.rarity != 1:
			item = current_avalable_abilities.pick_random()
	else:
		# get common item
		while item.rarity != 0:
			item = current_avalable_abilities.pick_random()
	return item


func update_money():
	money.text = str(player.gold)
	if reroll_cost > player.gold:
		reroll_button.disabled = true
	if shop_item1.price > player.gold:
		shop_item1.price_label.self_modulate = Color(0.749, 0, 0.059)
	if shop_item2.price > player.gold:
		shop_item2.price_label.self_modulate = Color(0.749, 0, 0.059)
	if shop_item3.price > player.gold:
		shop_item3.price_label.self_modulate = Color(0.749, 0, 0.059)
	if shop_item4.price > player.gold:
		shop_item4.price_label.self_modulate = Color(0.749, 0, 0.059)


func reset():
	unavalable_abilities = []
	current_avalable_abilities = []
	for ability in avalable_abilities:
		current_avalable_abilities.push_back(ability)
	reroll_shop()
	update_money()


func _on_reroll_button_pressed():
	reroll_shop()


func _on_next_floor_pressed():
	close()
