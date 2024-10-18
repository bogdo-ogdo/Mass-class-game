extends StaticBody2D
signal next_floor

var player_in_area : bool = false

func _input(event):
	if event.is_action_released("ui_interact") && player_in_area == true:
		emit_signal("next_floor")

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_area = true 


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_area = false
