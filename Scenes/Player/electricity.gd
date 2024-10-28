extends ColorRect

@export var weapon : Node2D
var on : bool
var enemis_in_area = []

func set_active(state : bool):
	on = state
	visible = state


func _on_timer_timeout():
	if on:
		for area in enemis_in_area:
			area.get_parent().health -= weapon.damage * .5
			area.get_parent().hit = true
			weapon.get_parent().damage_done += weapon.damage * .5


func _on_electric_area_2d_area_entered(area):
	if area.is_in_group("Enemy") && on:
		enemis_in_area.append(area)
		print(enemis_in_area)


func _on_electric_area_2d_area_exited(area):
	if area.is_in_group("Enemy"):
		enemis_in_area.erase(area)
