extends weapon_type
class_name MeatTongs


func _ready():
	bullet_type = "BBQ"
	damage = 2
	fire_rate = 5
	mana_cost = 2
	crit_chance = 20
	bullet_size = 1
	bullet_speed = 15
	bullet_spread = 3
	charge = true
	full_auto = true
	piercing = 2
	bounces = 2
	scale = .75
	chargeDamage = 1.3
	txture = "res://Assets/Weapons/Food Flingers.png"


func Update(_delta):
	anim_player.play("MeatTongs")
