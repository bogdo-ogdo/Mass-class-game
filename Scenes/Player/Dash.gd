extends Node2D

@onready var duration_timer = $duration_timer
@export var dash_ghost : PackedScene

var dash_delay : float = .4
var can_dash : bool = true
var sprite


func start_dash(texture, duration):
	sprite = texture
	duration_timer.wait_time = duration
	duration_timer.start()
	
	spawn_ghost()
	$ghost_timer.start()


func spawn_ghost():
	var dg = dash_ghost.instantiate()
	get_parent().get_parent().add_child(dg)
	
	dg.global_position = global_position
	dg.texture = sprite.texture
	dg.vframes = sprite.vframes
	dg.hframes = sprite.hframes
	dg.frame = sprite.frame
	dg.flip_h = sprite.flip_h


func is_dashing():
	return !duration_timer.is_stopped()


func end_dash():
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true


func _on_duration_timer_timeout():
	end_dash()


func _on_ghost_timer_timeout():
	if is_dashing():
		spawn_ghost()
		$ghost_timer.start()
