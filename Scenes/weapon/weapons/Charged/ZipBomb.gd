extends weapon_type
class_name ZipBomb


func _ready():
	bullet_type = "ZipBomb"
	damage = 10
	fire_rate = 2
	mana_cost = 10
	crit_chance = 20
	bullet_size = .75
	bullet_speed = 10
	bullet_spread = 3
	explotion_size = 1.75
	scale = .75
	txture = "res://Assets/Weapons/ZIPbobm.png"
	charge = true


func Update(_delta):
	anim_player.play("ZipBomb")
