extends Control

signal opened
signal closed
signal start
signal boss

@onready var u_sure : NinePatchRect = $"u_sure?"

var player : CharacterBody2D
var is_open : bool = false

func _ready():
	u_sure.visible = false
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta):
	if is_open && modulate.a < 1:
		modulate.a += .1
	elif !is_open && modulate.a > 0:
		modulate.a -= .05
	elif !is_open && modulate.a <= 0:
		visible = false


func open():
	modulate.a = 0
	get_tree().paused = true
	visible = true
	is_open = true
	opened.emit()


func close():
	get_tree().paused = false
	is_open = false
	closed.emit()


func _on_start_pressed():
	get_parent().get_parent().level = 1
	get_parent().get_parent().dungeon_floor = 0
	get_parent().get_parent().load_map()
	get_parent().get_parent().treasure.reset()
	player.reset()
	close()


func _on_quit_pressed():
	u_sure.visible = true


func _on_yes_pressed():
	get_tree().quit()


func _on_no_pressed():
	u_sure.visible = false


func _on_credits_pressed():
	get_parent().credits.open()


func _on_boss_fight_pressed():
	get_parent().get_parent().treasure.reset()
	get_parent().get_parent().level = 4
	get_parent().get_parent().dungeon_floor = 0
	get_parent().get_parent().load_map()
	player.reset()
	player.gold = 800
	close()
	get_parent().shop.open()


func _on_okay_pressed():
	$Panel.visible = false
