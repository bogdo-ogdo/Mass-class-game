extends Resource

class_name Ability

@export var ability_name : String
@export var description : String
@export var texture : Texture
@export var unique : bool
@export var rarity : int  # 0 = common(white), 1 = rare(blue), 2 =  
@export var cost : int

var player : CharacterBody2D
var weapon : CharacterBody2D
var quantity : int = 0

#func _ready():
	#player = get_tree().get_first_node_in_group("Player")
	#weapon = player.get_child(4)


