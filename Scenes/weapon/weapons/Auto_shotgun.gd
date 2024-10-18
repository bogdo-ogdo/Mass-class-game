extends weapon_type
class_name Auto_shotgun


func _ready():
	full_auto = true
	bullet_type = "BB"
	damage = 2
	fire_rate = 3
	mana_cost = 7
	projectiles = 6
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 15
	txture = "res://Assets/Weapons/auto_shotgun.png"


func Update(_delta):
	anim_player.play("Auto_shotgun")
