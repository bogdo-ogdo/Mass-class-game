extends PointLight2D

@export var flicker_interval_time : Vector2
@export var flickers : Vector2i
@export var flicker_speed : Vector2
@export var base_light_energy : float

@onready var flikerTimer : Timer = $Timer

var lightEnergy : float
var current_flickers : int = 0
var current_flicker_speed : float
var flickerTime : float

func _process(_delta):
	self.energy = base_light_energy * lightEnergy
	
	if current_flickers > 0:
		if flickerTime >= 1:
			flickerTime = 0
			current_flickers -= 1
			current_flicker_speed = randf_range(flicker_speed.x, flicker_speed.y)
		lightEnergy = .5 * cos(flickerTime*PI*2) + .5
		flickerTime += _delta * current_flicker_speed
		


func _on_timer_timeout():
	current_flicker_speed = randf_range(flicker_speed.x, flicker_speed.y)
	current_flickers = randi_range(flickers.x, flickers.y)
	flickerTime = 0
	flikerTimer.start(randf_range(flicker_interval_time.x, flicker_interval_time.y))
