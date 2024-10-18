extends weapon_type
class_name Banana


func _ready():
	bullet_type = "Banana"
	damage = 8
	fire_rate = 2
	mana_cost = 5
	crit_chance = 20
	bullet_size = 1
	bullet_speed = 7
	bullet_spread = 3
	bounces = 1
	txture = "res://Assets/Weapons/Banana.png"


func Update(_delta):
	anim_player.play("Banana")
