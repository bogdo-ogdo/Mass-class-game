extends weapon_type
class_name Knife


func _ready():
	bullet_type = "Knife"
	damage = 6
	fire_rate = 2
	mana_cost = 5
	crit_chance = 20
	bullet_size = 1
	bullet_speed = 15
	bullet_spread = 3
	charge = true
	chargeDamage = 1.2
	txture = "res://Assets/Weapons/Charged/knifeItem.png"


func Update(_delta):
	anim_player.play("Knife")
