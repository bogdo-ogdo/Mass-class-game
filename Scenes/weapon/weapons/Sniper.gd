extends weapon_type
class_name Sniper


func _ready():
	full_auto = false
	bullet_type = "Large"
	damage = 15
	fire_rate = 1
	mana_cost = 10
	crit_chance = 30
	bullet_size = .75
	bullet_speed = 20
	bullet_spread = 1
	piercing = 1
	txture = "res://Assets/Weapons/Sniper.png"


func Update(_delta):
	anim_player.play("Sniper")
