extends weapon_type
class_name Trench_gun


func _ready():
	bullet_type = "BB"
	damage = 3
	fire_rate = 2
	mana_cost = 10
	crit_chance = 10
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 25
	projectiles = 10
	txture = "res://Assets/Weapons/Sawed-OffWinchester1897.png"


func Update(_delta):
	anim_player.play("Trench_gun")
