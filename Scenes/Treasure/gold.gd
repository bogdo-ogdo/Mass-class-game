extends CharacterBody2D

@onready var gold_sprites : AnimationPlayer = $AnimationPlayer
@onready var attract : Area2D = $attract

var inital_direction : Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1))
var can_go_to_player : bool = false
var go_to_player : bool = false
var scale_factor : float = .8
var player : CharacterBody2D
var speed : float

func _ready():
	z_index = 2
	player = get_tree().get_first_node_in_group("Player")
	gold_sprites.play(str(randi_range(1,6)))
	speed = 100
	scale.x *= 1/get_parent().scale.x
	scale.y *= 1/get_parent().scale.y
	scale *= scale_factor
	attract.monitoring = false
	


func _process(delta):
	if can_go_to_player == true && go_to_player == true:
		speed = 500
		var direction = (player.global_position - global_position).normalized()
		var steering = ((direction * speed) - velocity) * delta * 1.5
		velocity += steering
	else:
		if speed > 0:
			velocity = inital_direction * speed
			speed -= 4
		else:
			velocity = Vector2.ZERO
	
	
	move_and_slide()


func _on_lock_on_timeout():
	can_go_to_player = true
	attract.monitoring = true


func _on_area_2d_area_entered(area):
	if area.is_in_group("Player_hitbox"):
		player.gold += 1
		player.gold_collected += 1
		queue_free()


func _on_attract_area_entered(area):
	if area.is_in_group("player_attract_radius"):
		go_to_player = true
