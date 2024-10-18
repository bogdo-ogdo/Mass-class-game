extends Area2D

signal close_gates
signal open_gates

@onready var area : CollisionShape2D = $CollisionShape2D
@onready var reset_timer : Timer = $reset_timer

var first_activation : bool = true
var enemies_spawned : bool = false
var summon_wave : bool = false
var spawn_places : Array = []
var can_spawn : bool = false
var player : CharacterBody2D
var alive_enemies : int = 0
var invalid_spawn : bool
var skip_spawn : bool = false
var xpos : float
var ypos : float

func _ready(): 
	get_parent().connect("clear_floor",on_clear_floor)
	player = get_tree().get_first_node_in_group("Player")


func _physics_process(_delta):
	if can_spawn:
		if summon_wave:
			summon_enemies()
			
		if enemies_spawned && alive_enemies == 0:
			emit_signal("open_gates")
			alive_enemies = 1
	
	var distance = abs(player.global_position - global_position)
	if distance.x < 600 && distance.y < 400:
		$PointLight2D.enabled = true
	else:
		$PointLight2D.enabled = false


func summon_enemies():
	summon_wave = false
	enemies_spawned = true
	for i in range(0,randi_range(4,6)):
		invalid_spawn = true
		skip_spawn = false
		while invalid_spawn:
			invalid_spawn = false
			xpos = randi_range(position.x-scale.x*8,position.x+scale.x*8)
			ypos = randi_range(position.y-scale.y*8,position.y+scale.y*8)
			if get_parent().tile_map.get_cell_tile_data(0,Vector2i(xpos/16,ypos/16)).get_custom_data("Spawnable"):
				var player_dist = (player.global_position - Vector2(xpos,ypos)).length()
				if player_dist > 100:
					for l in spawn_places:
						if Vector2i(xpos/16,ypos/16) == l:
							invalid_spawn = true
					if invalid_spawn == false:
						spawn_places.push_back(Vector2i(xpos/16,ypos/16))
				else:
					invalid_spawn = true
			else:
				invalid_spawn = true
			if invalid_spawn:
				if randi_range(1,3) == 1:
					invalid_spawn = false
					skip_spawn = true
				
		if !skip_spawn:
			var e = pick_enemy().instantiate()
			e.scale.x *= 1/scale.x
			e.scale.y *= 1/scale.y
			add_child(e)
			e.health *= get_parent().level + (float(get_parent().dungeon_floor-1))/3
			e.global_position.x = spawn_places[-1].x*16 + 8
			e.global_position.y = spawn_places[-1].y*16 + 8
			alive_enemies += 1


func pick_enemy():
	var emy = get_parent().enemies.pick_random()
	if emy.instantiate().rarity > 0:
		if randi_range(0,1) == 0:
			while emy.instantiate().rarity > 0:
				emy = pick_enemy()
	return emy


func _on_body_entered(body):
	if body.is_in_group("Player") && first_activation && can_spawn:
		emit_signal("close_gates")
		summon_wave = true
		first_activation = false


func on_clear_floor():
	emit_signal("open_gates")
	for child in get_children():
		child.queue_free()
	queue_free()


func _on_reset_timer_timeout():
	can_spawn = true
