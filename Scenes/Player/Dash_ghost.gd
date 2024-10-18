extends Sprite2D

var opacity = 1

func _physics_process(_delta):
	y_sort_enabled = true
	z_index = 1
	if opacity >= 0:
		opacity -= .03
		modulate.a = opacity
	else:
		queue_free()
