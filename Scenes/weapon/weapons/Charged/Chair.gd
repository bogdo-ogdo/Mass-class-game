extends weapon_type
class_name Chair


func _ready():
	bullet_type = "Chair"
	damage = 10
	fire_rate = 1
	mana_cost = 10
	crit_chance = 20
	bullet_size = 1
	bullet_speed = 15
	bullet_spread = 3
	charge = true
	chargeDamage = 1.2
	txture = "res://Assets/Weapons/Knockback/chair.png"


func Update(_delta):
	anim_player.play("Chair")
