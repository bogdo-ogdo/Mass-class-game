extends Node

@onready var room = preload("res://Scenes/Room/room.tscn")

var min_number_rooms = 7
var max_number_rooms = 12
var generation_chance = 15

func generate(room_seed):
	seed(room_seed)
	var dungeon = {}
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var size = floor(rng.randi_range(min_number_rooms, max_number_rooms))
	
	dungeon[Vector2(0,0)] = room.instantiate()
	size -= 1
	
	
	while size > 0:
		for i in dungeon.keys():
			if rng.randf_range(0,100) < generation_chance && size > 0:
				var direction = rng.randi_range(0,4)
				if(direction < 1):
					var new_room_position = i + Vector2(1, 0)
					if(!dungeon.has(new_room_position)):
						dungeon[new_room_position] = room.instantiate()
						size -= 1
					if dungeon.get(i).connected_rooms.get(Vector2(1, 0)) == null:
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(1, 0))
				elif direction < 2:
					var new_room_position = i + Vector2(-1, 0)
					if !dungeon.has(new_room_position):
						dungeon[new_room_position] = room.instantiate()
						size -= 1
					if dungeon.get(i).connected_rooms.get(Vector2(-1, 0)) == null:
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(-1, 0))
				elif direction < 3:
					var new_room_position = i + Vector2(0, 1)
					if !dungeon.has(new_room_position):
						dungeon[new_room_position] = room.instantiate()
						size -= 1
					if dungeon.get(i).connected_rooms.get(Vector2(0, 1)) == null:
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(0, 1))
				elif direction < 4:
					var new_room_position = i + Vector2(0, -1)
					if !dungeon.has(new_room_position):
						dungeon[new_room_position] = room.instantiate()
						size -= 1
					if dungeon.get(i).connected_rooms.get(Vector2(0, -1)) == null:
						connect_rooms(dungeon.get(i), dungeon.get(new_room_position), Vector2(0, -1))
	while !is_interesting(dungeon):
		for i in dungeon.keys():
			dungeon.get(i).queue_free()
		var sed = room_seed * rng.randf_range(-1,1) + rng.randf_range(-100,100)
		dungeon = generate(sed)
	return dungeon

func connect_rooms(room1, room2, direction):
	room1.connected_rooms[direction] = room2
	room2.connected_rooms[-direction] = room1
	room1.number_of_connections += 1
	room2.number_of_connections += 1

func is_interesting(dungeon):
	var rooms_with_four = 0
	var rooms_with_three = 0
	var rooms_with_one = 0
	var start_set = false
	var end_set = false
	var treasure_set = false
	
	for i in dungeon.keys():
		if dungeon.get(i).number_of_connections == 3:
			rooms_with_three += 1
		if dungeon.get(i).number_of_connections == 4:
			rooms_with_four += 1
		elif dungeon.get(i).number_of_connections == 1:
			rooms_with_one += 1
		
			if start_set == false:
				dungeon.get(i).start = true
				start_set = true
			elif treasure_set == false:
				dungeon.get(i).treasure = true
				treasure_set = true
			elif end_set == false:
				dungeon.get(i).end = true
				end_set = true
	if rooms_with_one == 3 && rooms_with_three >= 2 && rooms_with_four >= 0:
		return true
	else:
		return false
