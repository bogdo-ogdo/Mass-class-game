extends weapon_type
class_name P90


func _ready():
	full_auto = true
	bullet_type = "Large"
	damage = 1.5
	fire_rate = 15
	mana_cost = 1
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 6
	txture = "res://Assets/Weapons/P90.png"


func Update(_delta):
	anim_player.play("P90")
