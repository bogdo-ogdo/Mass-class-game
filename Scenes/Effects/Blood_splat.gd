extends CPUParticles2D

var counter = 10


func _ready():
	emitting = true

func _process(_delta):
	if counter > 0:
		counter -= 1
	else:
		emitting = false


func _on_timer_timeout():
	queue_free()
