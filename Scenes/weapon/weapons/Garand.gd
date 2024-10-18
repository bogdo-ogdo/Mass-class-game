extends weapon_type
class_name Garand


func _ready():
	full_auto = false
	bullet_type = "Large"
	damage = 7
	fire_rate = 2
	mana_cost = 6
	crit_chance = 20
	bullet_size = .75
	bullet_speed = 16
	bullet_spread = 2
	piercing = 1
	txture = "res://Assets/Weapons/M1Garand.png"


func Update(_delta):
	anim_player.play("Garand")
