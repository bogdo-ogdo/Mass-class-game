extends Control

var is_open : bool = false


func open():
	visible = true
	is_open = true


func close():
	visible = false
	is_open = false
	get_parent().credits.open()

func _input(event):
	if event.is_action_pressed("ui_cancel") && is_open:
		close()


func _on_return_pressed():
	close()
