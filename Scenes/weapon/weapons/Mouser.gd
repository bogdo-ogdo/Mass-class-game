extends weapon_type
class_name Mouser


func _ready():
	full_auto = true
	bullet_type = "Mouse"
	damage = 3
	fire_rate = 4
	mana_cost = 3
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 5
	bullet_spread = 5
	txture = "res://Assets/Weapons/MauserC96.png"


func Update(_delta):
	anim_player.play("Mouser")
