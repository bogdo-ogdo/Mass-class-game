extends weapon_type
class_name Syringe


func _ready():
	bullet_type = "Syringe"
	damage = 4
	fire_rate = 4
	mana_cost = 3
	crit_chance = 20
	bullet_size = 1.5
	bullet_speed = 10
	bullet_spread = 3
	piercing = 1
	txture = "res://Assets/Weapons/Charged/syringeItem.png"
	charge = true


func Update(_delta):
	anim_player.play("Syringe")
