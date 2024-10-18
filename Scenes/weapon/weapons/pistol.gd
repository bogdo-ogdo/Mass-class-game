extends weapon_type
class_name Pistol


func _ready():
	full_auto = false
	bullet_type = "Large"
	damage = 4
	fire_rate = 3
	mana_cost = 3
	crit_chance = 0
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 3
	txture = "res://Assets/Weapons/pistol.png"


func Update(_delta):
	anim_player.play("Pistol")
