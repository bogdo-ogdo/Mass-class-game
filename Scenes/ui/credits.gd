extends Control

var is_open : bool = false


func _process(_delta):
	if is_open && modulate.a < 1:
		modulate.a += .1
	elif !is_open && modulate.a > 0:
		modulate.a -= .05
	elif !is_open && modulate.a <= 0:
		visible = false


func open():
	visible = true
	is_open = true


func close():
	is_open = false


func _on_return_pressed():
	close()
