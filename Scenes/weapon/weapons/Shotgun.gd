extends weapon_type
class_name Shotgun


func _ready():
	full_auto = false
	bullet_type = "BB"
	damage = 3
	fire_rate = 1.5
	mana_cost = 10
	projectiles = 6
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 15
	txture = "res://Assets/Weapons/Shotgun.png"


func Update(_delta):
	anim_player.play("Shotgun")
