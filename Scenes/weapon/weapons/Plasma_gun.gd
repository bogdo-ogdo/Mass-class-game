extends weapon_type
class_name Plasma_gun


func _ready():
	bullet_type = "Plasma_ball"
	full_auto = false
	damage = 10
	fire_rate = 1
	mana_cost = 10
	crit_chance = 0
	bullet_size = 1
	bullet_speed = 5
	bullet_spread = 3
	explotion_size = 1.5
	explotion_type = "Plasma"
	txture = "res://Assets/Weapons/PlasmaBlaster.png"
	sound = "res://audio/Weapon/Laser.wav"


func Update(_delta):
	anim_player.play("Plasma_gun")
