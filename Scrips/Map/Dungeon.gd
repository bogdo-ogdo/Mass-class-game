extends Node2D

signal clear_floor

@export var player : CharacterBody2D
@export var ladder : StaticBody2D
@export var gate : PackedScene
@export var new_floor_timer : Timer
@export var gate_perimeter : PackedScene
@export var enemies : Array[PackedScene]
@export var shop : Control
@export var torch_light : PackedScene
@export var room_light : PackedScene
@export var minimap_item : PackedScene

@export var barrel : PackedScene
@export var pot : PackedScene
@export var pillar : PackedScene
@export var bookshelf : PackedScene
@export var tall_pillar : PackedScene

@onready var tile_map : TileMap = $Level
@onready var treasure : StaticBody2D = $Treasure
@onready var minimap : TileMap = $Minimap/Container/MiniMap
@onready var boss_lvl : PackedScene = preload("res://Scenes/Boss_level/boss_level.tscn")
@onready var pause_menu : Control = $Menus/Pause_menu
@onready var start_menu : Control = $Menus/Start_menu
@onready var credits : Control = $Menus/Credits
@onready var music : AudioStreamPlayer = $Music

@onready var lvl1_music = preload("res://audio/Level music/Green Gobby Stobby.mp3")
@onready var lvl2_music = preload("res://audio/Level music/ZHAO_Ethan_Ambience_and_Dance_-_First_Draft.mp3")
@onready var lvl3_music = preload("res://audio/Level music/Fuck_I_hate_being_poor.wav")
@onready var boss_music = preload("res://audio/Boss_music/Middle.wav")

var gates_up : bool = false
var dungeon = {}
var room_size : Vector2
var dungeon_floor : int = 0
var level : int = 1
var map_wrap : Array[Vector2i]
var map_void : Array[Vector2i]
var map_tile : Array[Vector2i]
var shadows : bool = true


func _ready():
	tile_map.clear()

func _physics_process(_delta):
	minimap.position = Vector2(-player.global_position.x/16+64,-player.global_position.y/16+64)


func load_map():
	gates_up = false
	minimap.clear()
	tile_map.clear()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	dungeon = dungeon_generation.generate(rng.randf_range(-100,100))
	map_tile = []
	map_void = []
	map_wrap = []
	shadows = pause_menu.shadows
	
	var cdor_x_st = tile_map.tile_set.get_pattern(0)
	var cdor_x_md = tile_map.tile_set.get_pattern(1)
	var cdor_x_en = tile_map.tile_set.get_pattern(2)
	
	var cdor_y_st = tile_map.tile_set.get_pattern(3)
	var cdor_y_md = tile_map.tile_set.get_pattern(4)
	var cdor_y_en = tile_map.tile_set.get_pattern(5)
	
	dungeon_floor += 1
	if dungeon_floor == 4:
		level += 1
		dungeon_floor = 1
	
	if level == 1:
		$CanvasModulate.color = Color(.1,.1,.1)
		$Music.stream = lvl1_music
		$Music.playing = true
	if level == 2:
		$CanvasModulate.color = Color(0.25,0.25,0.25)
		$Music.stream = lvl2_music
		$Music.playing = true
	if level == 3:
		$CanvasModulate.color = Color(.1,.1,.1)
		$Music.stream = lvl3_music
		$Music.playing = true
	
	for child in get_children():
		if child.is_in_group("clear"):
			child.queue_free()
	
	if level == 4:
		if dungeon_floor == 1:
			$Music.playing = false
			$CanvasModulate.color = Color(.1,.1,.1)
			var bl = boss_lvl.instantiate()
			add_child(bl)
			minimap.visible = false
	else:
		minimap.visible = true
	
		for i in dungeon:
			var rl = room_light.instantiate()
			
			if dungeon.get(i).start:
				tile_map.set_pattern(0, Vector2(34, 26)*i, tile_map.tile_set.get_pattern(6))
				player.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
				add_child(rl)
				rl.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
				rl.scale = Vector2(16,16)
			elif dungeon.get(i).treasure:
				tile_map.set_pattern(0, Vector2(34, 26)*i, tile_map.tile_set.get_pattern(6))
				treasure.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
				add_child(rl)
				rl.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
				rl.scale = Vector2(16,16)
			elif dungeon.get(i).end:
				tile_map.set_pattern(0, Vector2(34, 26)*i, tile_map.tile_set.get_pattern(6))
				ladder.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
				add_child(rl)
				rl.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
				rl.scale = Vector2(16,16)
			else:
				var rooms = tile_map.tile_set.get_pattern(rng.randi_range(7,21))
				room_size = Vector2(-5,-6)
				tile_map.set_pattern(0, Vector2(34, 26)*i, rooms)
				for l in range(0,35):
					if tile_map.get_cell_atlas_coords(0,Vector2i(34*i.x+l,26*i.y+13)) != Vector2i(4,3):
						room_size.x += 1
				for l in range(0,27):
					if tile_map.get_cell_atlas_coords(0,Vector2i(34*i.x+16,26*i.y+l)) != Vector2i(4,3):
						room_size.y += 1
				_add_gate_perimeter(i.x,i.y,room_size)
		
		for i in dungeon.keys():
			
			var c_rooms = dungeon.get(i).connected_rooms
			var mid_pos = Vector2i(34*i.x+14,26*i.y+10)
			var count = 0
			if c_rooms.get(Vector2(1, 0)) != null:
				
				count = 0
				while true:
					if tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(5,1):
						tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_st)
						_spawn_gate(mid_pos.x+count+1,mid_pos.y+3,true)
						_spawn_gate(mid_pos.x+count+1,mid_pos.y+4,true)
					elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(-1,-1) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(4,3):
						tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_md)
					elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(0,1):
						tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_en)
						_spawn_gate(mid_pos.x+count-1,mid_pos.y+3,true)
						_spawn_gate(mid_pos.x+count-1,mid_pos.y+4,true)
						break
					count += 1
		
			if c_rooms.get(Vector2(0, 1)) != null:
				count = 0
				
				while true:
					if tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(1,7) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(4,7):
						tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_st)
						_spawn_gate(mid_pos.x+1,mid_pos.y+count+2,false)
						_spawn_gate(mid_pos.x+2,mid_pos.y+count+2,false)
					elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(-1,-1) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(4,3):
						tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_md)
					elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(1,0):
						tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_en)
						_spawn_gate(mid_pos.x+1,mid_pos.y+count+1,false)
						_spawn_gate(mid_pos.x+2,mid_pos.y+count+1,false)
						break
					count += 1
		
		for i in tile_map.get_used_cells(0):
			
			if tile_map.get_cell_tile_data(0,i).get_custom_data("minimap") == 1:
				minimap.set_cell(0,i,0,Vector2i(0,0))
			elif tile_map.get_cell_tile_data(0,i).get_custom_data("minimap") == 2:
				minimap.set_cell(0,i,0,Vector2i(1,0))
				if tile_map.get_cell_atlas_coords(0,i).x < 5:
					map_wrap.push_front(i)
			
			if tile_map.get_cell_atlas_coords(0,i).x > 5 && tile_map.get_cell_atlas_coords(0,i).y < 3:
				map_tile.push_back(i)
			elif tile_map.get_cell_atlas_coords(0,i).x > 5 && tile_map.get_cell_atlas_coords(0,i).y > 2:
				map_void.push_back(i)
			
			if tile_map.get_cell_atlas_coords(0,i).y == 8 && tile_map.get_cell_atlas_coords(0,i).x < 6:
				if level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,1)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,1)
			
			if tile_map.get_cell_atlas_coords(0,i) == Vector2i(1,6):
				var tl = torch_light.instantiate()
				add_child(tl)
				tl.shadow_enabled = shadows
				tl.position = Vector2(i.x*16+8,i.y*16+6)  
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(1,6))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(1,6))
			
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(3, 3):
				if level == 1:
					tile_map.set_cells_terrain_path(0,[i],0,0)
				elif level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,1)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,1)
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(1, 0):
				if level == 1:
					tile_map.set_cells_terrain_path(0,[i],0,1)
				elif level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,4)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,3)
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(1, 7) or tile_map.get_cell_atlas_coords(0,i) == Vector2i(4, 7):
				if level == 1:
					tile_map.set_cells_terrain_path(0,[i],0,2)
				if level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,5)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,4)
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 1):
				if level == 1:
					tile_map.set_cells_terrain_path(0,[i],0,3)
				if level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,6)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,5)
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 1):
				if level == 1:
					tile_map.set_cells_terrain_path(0,[i],0,4)
				elif level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,7)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,6)
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(1, 1):
				if level == 1:
					tile_map.set_cells_terrain_path(0,[i],0,5)
				if level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,3)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,2)
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(4, 1):
				if level == 1:
					tile_map.set_cells_terrain_path(0,[i],0,5)
				if level == 2:
					tile_map.set_cells_terrain_path(0,[i],1,3)
				elif level == 3:
					tile_map.set_cells_terrain_path(0,[i],2,2)
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 7):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(5, 7))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(5, 7))
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 7):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(0, 7))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(0, 7))
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 0):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(0, 0))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(0, 0))
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 0):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(5, 0))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(5, 0))
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 4):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(5, 4))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(5, 4))
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 5):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(5, 5))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(5, 5))
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 5):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(0, 5))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(0, 5))
			elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 4):
				if level == 2:
					tile_map.set_cell(0,i,1,Vector2i(0, 4))
				elif level == 3:
					tile_map.set_cell(0,i,0,Vector2i(0, 4))
			
			#if tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "barrel":
				#var brl = barrel.instantiate()
				#add_child(brl)
				#brl.position = Vector2(i.x*16+7,i.y*16+7)
			#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "pot":
				#var pt = pot.instantiate()
				#add_child(pt)
				#pt.position = Vector2(i.x*16+7,i.y*16+7)
			#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "bookshelf":
				#var brl = bookshelf.instantiate()
				#add_child(brl)
				#brl.position = Vector2(i.x*16+7,i.y*16+7)
			#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "pillar":
				#var brl = pillar.instantiate()
				#add_child(brl)
				#brl.position = Vector2(i.x*16+7,i.y*16+7)
			#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "tall_pillar":
				#var brl = tall_pillar.instantiate()
				#add_child(brl)
				#brl.position = Vector2(i.x*16+7,i.y*16+7)
		if level == 2:
			tile_map.set_cells_terrain_connect(0,map_tile,1,2)
			tile_map.set_cells_terrain_connect(0,map_void,1,0)
		elif level == 3:
			tile_map.set_cells_terrain_connect(0,map_tile,2,1)
			tile_map.set_cells_terrain_connect(0,map_void,2,0)
		
		load_minimap()
	$NavigationRegion2D.bake_navigation_polygon()


func load_minimap():
	$Minimap/Container/MiniMap/minimap_chest.position = Vector2(treasure.position.x/16+.5,treasure.position.y/16+.5)
	$Minimap/Container/MiniMap/minimap_ladder.position = Vector2(ladder.position.x/16+.5,ladder.position.y/16+.5)


func _add_gate_perimeter(x,y,s):
	var gp = gate_perimeter.instantiate()
	add_child(gp)
	gp.position = Vector2((34*x+16)*16,(26*y+12.5)*16)
	gp.scale = Vector2(s.x,s.y)
	gp.connect('close_gates',_on_player_enter_perimeter)
	gp.connect('open_gates',_on_enemies_cleared)


func _spawn_gate(x,y,side_facing:bool):
	var g = gate.instantiate()
	add_child(g)
	g.position = Vector2(x*16, y*16)
	g.side_facing = side_facing


func _on_player_enter_perimeter():
	gates_up = true


func _on_enemies_cleared():
	gates_up = false


func _on_ladder_next_floor():
	emit_signal("clear_floor")
	if level == 4 && dungeon_floor == 2:
		player.win = true
	else:
		shop.open()
		tile_map.clear()
		minimap.clear()
		load_map()
		treasure.reset()


func _on_player_restart_game():
	emit_signal("clear_floor")
	tile_map.clear()
	minimap.clear()
	load_map()
	treasure.reset()


func _on_timer_timeout():
	pass


func _on_pause_menu_closed():
	get_tree().paused = false


func _on_music_finished():
	if level == 4:
		$Music.stream = boss_music
	$Music.playing = true
