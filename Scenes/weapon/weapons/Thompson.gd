extends weapon_type
class_name Thompson


func _ready():
	full_auto = true
	bullet_type = "Large"
	damage = 2
	fire_rate = 10
	mana_cost = 1
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 10
	txture = "res://Assets/Weapons/ThombsonSMG.png"


func Update(_delta):
	anim_player.play("Thompson")
