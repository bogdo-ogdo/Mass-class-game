extends weapon_type
class_name Money_gun


func _ready():
	full_auto = false
	bullet_type = "coin"
	damage = 15
	fire_rate = 3
	mana_cost = 50
	crit_chance = 0
	bullet_size = 1
	bullet_speed = 10
	bullet_spread = 3
	money_shot = true
	txture = "res://Assets/Weapons/MoneyLauncher.png"


func Update(_delta):
	anim_player.play("Money_gun")
