extends weapon_type
class_name MiniGun


func _ready():
	full_auto = true
	bullet_type = "Large"
	damage = 3
	fire_rate = 15
	mana_cost = 1
	projectiles = 1
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 10
	txture = "res://Assets/Weapons/MiniGun.png"


func Update(_delta):
	anim_player.play("MiniGun")
