extends weapon_type
class_name Grenade_launcher


func _ready():
	bullet_type = "Large"
	damage = 10
	fire_rate = 1
	mana_cost = 10
	crit_chance = 0
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 5
	explotion_size = 1.75
	txture = "res://Assets/Weapons/GrenadeLauncher.png"


func Update(_delta):
	anim_player.play("Grenade_launcher")
