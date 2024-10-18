extends PointLight2D

var player : CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta):
	
	var distance = abs(player.global_position - global_position)
	if distance.x < 450 && distance.y < 300:
		enabled = true
	else:
		enabled = false
