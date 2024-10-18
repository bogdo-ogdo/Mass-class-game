extends Line2D

var max_trail_length : int = 10
var trail_queue : Array

func _process(_delta):
	var pos = get_parent().position
	trail_queue.push_front(pos)
	if trail_queue.size() > max_trail_length:
		trail_queue.pop_back()
	clear_points()
	for point in trail_queue:
		add_point(point)
