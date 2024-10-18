extends weapon_type
class_name Laser_pistol


func _ready():
	bullet_type = "Laser"
	damage = 4
	fire_rate = 4
	mana_cost = 3
	crit_chance = 20
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 3
	piercing = 1
	txture = "res://Assets/Weapons/LaserPistol.png"
	sound = "res://audio/Weapon/Laser.wav"


func Update(_delta):
	anim_player.play("Laser_pistol")
