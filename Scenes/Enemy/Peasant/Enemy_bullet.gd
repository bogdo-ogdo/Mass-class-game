extends CharacterBody2D

@onready var enemy_bullet : PackedScene = preload("res://Scenes/Enemy/Peasant/enemy_bullet.tscn")
var player : CharacterBody2D
var speed = 100
var damage = 1
var scale_factor = 1
var can_split : bool = false
var split : bool = false
var shots : Vector2 = Vector2(10,10)
var ff : bool = true

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
	scale.x *= 1/get_parent().scale.x
	scale.y *= 1/get_parent().scale.y
	scale *= scale_factor
	
func _physics_process(delta):
	if ff:
		visible = true
		ff = false
	else:
		$Area2D.monitoring = true
	position += transform.x * speed * delta
	z_index = 1
	if split:
		var angle : float = 0
		var shot = randi_range(shots.x, shots.y)
		for i in range(shot):
			spawn_bullet(angle)
			angle += 360.0/shot
		queue_free()


func _on_area_2d_area_entered(area):
	if area.is_in_group("Player_hitbox"):
		if player.dash.is_dashing() == false:
			player.current_health -= damage
			player.damage_taken += damage
			player.hit = true
			queue_free()


func _on_area_2d_body_entered(body):
	if !body.is_in_group("Enemy") && !body.is_in_group("Player"):
		if can_split:
			split = true
		else:
			queue_free()

func spawn_bullet(angle):
	var eb = enemy_bullet.instantiate()
	get_parent().add_child(eb)
	eb.rotation_degrees = angle
	eb.can_split = false
	eb.global_position = global_position


func _on_visible_on_screen_notifier_2d_screen_entered():
	$Sprite2D.visible = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	$Sprite2D.visible = false
