extends weapon_type
class_name Slimer


func _ready():
	full_auto = true
	bullet_type = "Slime"
	damage = 2
	fire_rate = 4
	mana_cost = 3
	projectiles = 1
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 3
	bounces = 5
	txture = "res://Assets/Weapons/SuperSoaker.png"


func Update(_delta):
	anim_player.play("Slimer")
