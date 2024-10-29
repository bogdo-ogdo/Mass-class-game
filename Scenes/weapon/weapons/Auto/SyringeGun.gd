extends weapon_type
class_name SyringeGun


func _ready():
	bullet_type = "Syringe"
	damage = 3
	fire_rate = 6
	mana_cost = 2
	crit_chance = 20
	bullet_size = 1
	bullet_speed = 15
	bullet_spread = 3
	full_auto = true
	piercing = 2
	scale = .5
	txture = "res://Assets/Weapons/TF2syringegun.png"


func Update(_delta):
	anim_player.play("SyringeGun")
