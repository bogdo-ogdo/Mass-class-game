extends Node2D

@onready var boss : PackedScene = preload("res://Scenes/Enemy/Boss/boss.tscn")
@onready var music_start = preload("res://audio/Boss_music/Start.wav")
@onready var music_mid = preload("res://audio/Boss_music/Middle.wav")

var boss_killed : bool = false
var gates_up : bool = false
var spawn_boss : bool = false
var boss_spawned : bool = false
var alive_enemies : int
var shadows : bool = true

func _ready():
	get_parent().music.stream = music_start
	get_parent().music.playing = true
	boss_killed = false
	for i in get_parent().get_children():
		if i.is_in_group("Player"):
			i.global_position = $Player_pos.global_position
		elif i .is_in_group("Treasure"):
			i.global_position = $Chest_pos.global_position
		elif i .is_in_group("Ladder"):
			i.global_position = $Ladder_pos.global_position


func _process(_delta):
	if boss_killed:
		gates_up = false
	if spawn_boss:
		var b = boss.instantiate()
		add_child(b)
		b.global_position = $Boss_pos.global_position
		boss_spawned = true
		spawn_boss = false
	if alive_enemies > 0:
		gates_up = true
	else:
		gates_up = false
	if get_parent().pause_menu.shadows:
		if !shadows:
			shadows = true
			shadow()
	else:
		if shadows:
			shadows = false
			shadow()


func shadow():
	for i in $Lights.get_children():
		if i.is_in_group("Shadow"):
			i.shadow_enabled = shadows


func _on_music_start_body_entered(body):
	if body.is_in_group("Player"):
		if !get_parent().music.playing:
			get_parent().music.play()


func _on_door_close_body_entered(body):
	if body.is_in_group("Player") && !boss_spawned:
		spawn_boss = true
		alive_enemies += 1
