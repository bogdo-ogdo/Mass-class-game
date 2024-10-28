extends Area2D

var is_colliding : bool = true

var vspeed : float = randf_range(-8,-4)
var hspeed : float = randf_range(-2,2)
var angle : float

var blood_acc : float = randf_range(0.05,0.1)

var do_wobble = false

var max_life : float = randf_range(5,15)
var life : float = 0

var draw_surface : blood_map


func _physics_process(_delta):
	if !is_colliding:
		do_wobble = false
		vspeed = lerp(vspeed,5.1,0.02)
		hspeed = lerp(hspeed,0.01,0.02)
		visible = true
	else:
		if draw_surface != null:
			draw_surface.draw_blood(position)
		
		life += 1
		if life > max_life:
			queue_free()
		
		if vspeed > 3:
			vspeed = 3
		vspeed = lerp(vspeed, 0.1, blood_acc)
		
		if abs(hspeed) > 0.1:
			hspeed = lerp(hspeed,0.01,0.1)
		else:
			do_wobble = true
		visible = true
		
		if do_wobble:
			hspeed += randf_range(-.01,.01)
			hspeed = clamp(hspeed,-.1,.1)
		
		var vel = Vector2(hspeed, vspeed).rotated(angle)
		
		position += vel

func _on_body_entered(_body):
	is_colliding = true


func _on_body_exited(_body):
	is_colliding = false
