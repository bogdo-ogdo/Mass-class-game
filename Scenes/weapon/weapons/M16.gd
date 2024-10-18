extends weapon_type
class_name M16


func _ready():
	full_auto = true
	bullet_type = "Large"
	damage = 2
	fire_rate = 8
	mana_cost = 1.5
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 5
	txture = "res://Assets/Weapons/M16.png"


func Update(_delta):
	anim_player.play("M16")
