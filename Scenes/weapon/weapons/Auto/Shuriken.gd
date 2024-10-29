extends weapon_type
class_name Shuriken


func _ready():
	bullet_type = "Shuriken"
	damage = 3
	fire_rate = 4
	mana_cost = 2
	crit_chance = 20
	bullet_size = 1
	bullet_speed = 15
	bullet_spread = 3
	charge = false
	full_auto = true
	piercing = 2
	bounces = 2
	scale = .5
	txture = "res://Assets/Weapons/Shuriken (1).png"


func Update(_delta):
	anim_player.play("Shuriken")
