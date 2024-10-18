extends StaticBody2D

@export var anim_player : AnimationPlayer
@export var collision_shape : CollisionShape2D

var open_animation_finished : bool = false
var parent_room : Rect2
var first_update : bool = true
var side_facing = false


func _process(_delta):
	if first_update == true:
		if side_facing == true:
			anim_player.play("side_gate_idle")
			collision_shape.rotation_degrees = 90
		else:
			anim_player.play("x_facing_idle")
		first_update = false
	
	if get_parent().gates_up == true && open_animation_finished == false:
		if side_facing == true:
			anim_player.play("side_gate_open")
		else:
			anim_player.play("x_facing_open")
		open_animation_finished = true
		
	elif get_parent().gates_up == false && open_animation_finished == true:
		if side_facing == true:
			anim_player.play("side_gate_close")
		else:
			anim_player.play("x_facing_close")
		open_animation_finished = false


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "side_gate_close" or anim_name == "x_facing_close":
		anim_player.play("side_gate_idle")
