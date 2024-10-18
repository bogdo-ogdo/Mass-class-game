extends weapon_type
class_name Toilet


func _ready():
	full_auto = true
	bullet_type = "Poo"
	damage = 2
	fire_rate = 5
	mana_cost = 1
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 10
	explotion_size = 1.5
	bounces = 2
	txture = "res://Assets/Weapons/Toilet.png"


func Update(_delta):
	anim_player.play("Toilet")
