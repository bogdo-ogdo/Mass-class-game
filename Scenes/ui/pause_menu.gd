extends Control

signal opened
signal closed

@onready var ability_display : Control = $Ability_display
@export var canvas : WorldEnvironment
@export var minimap : TileMap

var is_open : bool = false
var shadows : bool = true

func _ready():
	$VBoxContainer/HBoxContainer/VBoxContainer2/Gama_Slider.value = 100
	$VBoxContainer/HBoxContainer/VBoxContainer2/Minimap_slider.value = 50
	$VBoxContainer/ButtonContainer/Return/u_sure.visible = false


func _process(_delta):
	if is_open && modulate.a < 1:
		modulate.a += .1
	elif !is_open && modulate.a > 0:
		modulate.a -= .1
	elif !is_open && modulate.a <= 0:
		visible = false



func open():
	modulate.a = 0
	visible = true
	is_open = true
	opened.emit()
	get_tree().paused = true
	$Level_indicator.text = "Level "+str(get_parent().get_parent().level)+ " Floor " + str(get_parent().get_parent().dungeon_floor)


func close():
	is_open = false
	get_tree().paused = false
	closed.emit()
	$VBoxContainer/ButtonContainer/Return/u_sure.visible = false


func _on_shop_shop_closed():
	ability_display.update()


func _on_h_slider_value_changed(value):
	canvas.environment.adjustment_brightness = value/100


func _on_return_pressed():
	$VBoxContainer/ButtonContainer/Return/u_sure.visible = true


func _on_resume_pressed():
	close()


func _on_minimap_slider_value_changed(value):
	minimap.modulate.a = value/100
	minimap.get_child(0).modulate.a = value/100


func _on_check_box_toggled(toggled_on):
	if toggled_on:
		for i in get_parent().get_parent().get_children():
			if i.is_in_group("Shadow"):
				i.shadow_enabled = false
			shadows = false
	else:
		for i in get_parent().get_parent().get_children():
			if i.is_in_group("Shadow"):
				i.shadow_enabled = true
			shadows = true


func _on_particles_toggled(toggled_on):
	if toggled_on:
		get_parent().get_parent().player.get_child(4).particles = false
	else:
		get_parent().get_parent().player.get_child(4).particles = true


func _on_resume_2_pressed():
	close()
	get_parent().start_menu.open()


func _on_resume_3_pressed():
	$VBoxContainer/ButtonContainer/Return/u_sure.visible = false
