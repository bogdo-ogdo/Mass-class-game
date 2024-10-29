extends weapon_type
class_name The_scream


func _ready():
	full_auto = true
	flamethrow = true
	bullet_type = "scream"
	damage = .75
	fire_rate = 60
	mana_cost = .5
	crit_chance = 0
	bullet_size = .2
	bullet_speed = 4
	bullet_spread = 1.5
	txture = "res://Assets/Weapons/scream.png"
	sound = "res://audio/Weapon/flamethrower.wav"


func Update(_delta):
	anim_player.play("The_scream")
