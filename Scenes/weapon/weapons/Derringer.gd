extends weapon_type
class_name Derringer


func _ready():
	full_auto = false
	bullet_type = "Large"
	damage = 7
	fire_rate = 2
	mana_cost = 3
	crit_chance = 10
	bullet_size = 2
	bullet_speed = 5
	bullet_spread = 5
	txture = "res://Assets/Weapons/Derringer.png"


func Update(_delta):
	anim_player.play("Derringer")
