extends TileMapLayer

class_name blood_map
# Called when the node enters the scene tree for the first time.
var bloodDraw : Array = []

func _ready():
	clear_blood()

func draw_blood(pos : Vector2):
	var cellPos = Vector2i(int(pos.x/2), int(pos.y/2))
	bloodDraw.append(cellPos)
	

func clear_blood():
	clear()


func _on_timer_timeout():
	if bloodDraw.size() > 0:
		set_cells_terrain_connect(bloodDraw, 0, 0)
		bloodDraw = []
