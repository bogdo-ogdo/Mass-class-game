extends StaticBody2D

@onready var anim_player = $AnimationPlayer
@onready var weapon_pickup = $Weapon_pickup
@onready var instructions = $instructions

@export var shader_value : float = 1

var player_weapon : CharacterBody2D
var avalable_weapons : Array = []
var current_weapon : weapon_type
var new_weapon : weapon_type
var opened : bool = false
var can_interact : bool = false

func _ready():
	player_weapon = get_tree().get_first_node_in_group("Weapon")
	for weapon in player_weapon.get_child(2).get_children():
		avalable_weapons.push_back(weapon)
	anim_player.play("idle")
	choose_weapon()


func reset():
	opened = false
	weapon_pickup.visible = false
	anim_player.play("idle")
	choose_weapon()


func _physics_process(_delta):
	weapon_pickup.material.set_shader_parameter("progress", shader_value)


func choose_weapon():
	current_weapon = avalable_weapons.pick_random()
	if current_weapon == player_weapon.get_child(2).current_weapon:
		choose_weapon()
	else:
		weapon_pickup.texture = load(current_weapon.txture)


func _input(event):
	if event.is_action_pressed("ui_interact") && !opened && can_interact:
		if !anim_player.is_playing():
			anim_player.play("opening")
	elif event.is_action_pressed("ui_interact") && opened && can_interact:
		swap()


func swap():
	new_weapon = player_weapon.get_child(2).current_weapon
	player_weapon.get_child(2).current_weapon = current_weapon
	current_weapon = new_weapon
	weapon_pickup.texture = load(current_weapon.txture)
	player_weapon.update_weapon_parameters()
	player_weapon.get_parent().update_abilities()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "opening":
		opened = true
		anim_player.play("opened")


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		can_interact = true
		instructions.visible = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		can_interact = false
		instructions.visible = false
