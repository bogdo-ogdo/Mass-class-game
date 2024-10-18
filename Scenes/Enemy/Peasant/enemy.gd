extends CharacterBody2D
class_name enemy

signal player_damage

@onready var enemy_bullet : PackedScene = preload("res://Scenes/Enemy/Peasant/enemy_bullet.tscn")
@onready var gold : PackedScene = preload("res://Scenes/Treasure/gold.tscn")
@onready var gunshot = preload("res://audio/Weapon/gunshot.wav")
@onready var die_sound = preload("res://audio/Enemy/human_die.wav")
@onready var alt_animation : AnimationPlayer = $hit_AnimationPlayer
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var attack_timer : Timer = $Attack_timer
@onready var idle_timer : Timer = $Idle_timer
@onready var raycast : RayCast2D = $RayCast2D
@onready var nav_timer : Timer = $Nav_timer
@onready var sprite : Sprite2D = $Sprite2D
@onready var gun : Sprite2D = $Gun

@export var approach_dist : float
@export var run_dist : float 
@export var gold_drop : Vector2
@export var move_speed : float 
@export var health : float 
@export var damage : float
@export var rarity : int
@export var reload : Vector2
@export var attack_type : String
@export var shots : Vector2
@export var flip_h : bool
@export var delay : float
@export var spread : float
@export var shooot : bool = false
@export var spawn_value : float

var can_move : bool
var can_attack : bool = false
var target_position : Vector2
var player : CharacterBody2D
var rotation_speed = 15
var shots_left : int
var random_num : float
var hit : bool = false
var wander : bool
var spawn : bool
var gold_spawned : bool = false

enum {
	APROACH,
	IDLE,
	RUN,
}

var state = IDLE


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	can_move = false
	spawn = true
	spawn_value = 1
	sprite.material.set_shader_parameter("progress", spawn_value)
	gun.material.set_shader_parameter("progress", spawn_value)
	if randi_range(0,1) == 1:
		wander = true
	else:
		wander = false
	y_sort_enabled = true
	z_index = 1
	$Hit.energy = 0
	$sound.pitch_scale = randf_range(.75,1.4)


func _physics_process(delta: float) -> void:
	if spawn == true:
		spawn_value -= .015
		sprite.material.set_shader_parameter("progress", spawn_value)
		gun.material.set_shader_parameter("progress", spawn_value)
		can_move = false
		velocity = Vector2.ZERO
		if spawn_value <= 0:
			spawn = false
			can_move = true
			attack_timer.start(randf_range(1,reload.y))
	
	if shooot:
		var angle : float = 0
		var shot = randi_range(shots.x, shots.y)
		for i in range(shot):
			spawn_bullet(angle)
			angle += spread/shot
		attack_timer.start(randf_range(reload.x,reload.y))
		shooot = false
	
	if health <= 0:
		if !gold_spawned:
			die()
			$sound.stream = die_sound
			$sound.play()
			gold_spawned = true
		spawn_value += .02
		velocity = Vector2.ZERO
		sprite.material.set_shader_parameter("progress", spawn_value)
		gun.material.set_shader_parameter("progress", spawn_value)
		$collision_damage.monitoring = false
		$Area2D.monitorable = false
		can_attack = false
	
	if can_attack == true:
		if !raycast.is_colliding():
			shoot()
		else:
			state = APROACH
	
	if velocity.length() < 2:
		if !animation.current_animation == "jump":
			animation.play("p_idle")
	else:
		if !animation.current_animation == "jump":
			animation.play("p_run")
	
	if hit == true:
		alt_animation.play("hit")
		hit = false
	
	if can_move && !raycast.is_colliding():
		var direction = (nav_agent.get_next_path_position() - global_position).normalized()
		var steering = ((direction * move_speed) - velocity) * delta * 1.2
		velocity += steering
	elif raycast.is_colliding():
		velocity = (nav_agent.get_next_path_position() - global_position).normalized() * move_speed/2
	else:
		velocity = Vector2.ZERO
	
	rotate_to_player(delta)
	move_and_slide()


func rotate_to_player(delta):
	var direction = (player.position - gun.global_position) #target global position if is an entity
	var gunAngleTo = gun.transform.x.angle_to(direction)
	gun.rotation += (sign(gunAngleTo) * min(delta * rotation_speed, abs(gunAngleTo)))
	gun.rotation_degrees = round_to_dec(gun.rotation_degrees, -1)
	
	if direction.x > 0:
		if flip_h:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		gun.scale.y = 1
	elif direction.x < 0:
		if flip_h:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		gun.scale.y = -1


func round_to_dec(num, digit):
	return round(num * pow(15.0, digit)) / pow(15.0, digit)


func spawn_bullet(angle):
	$sound.stream = gunshot
	$sound.play()
	var eb = enemy_bullet.instantiate()
	get_parent().get_parent().add_child(eb)
	var direction = global_position - player.global_position
	if attack_type == "Slime":
		eb.rotation_degrees = angle
	elif attack_type == "Even":
		eb.rotation_degrees = angle + gun.rotation_degrees
	else:
		eb.rotation_degrees = rad_to_deg(atan2(direction.x,direction.y))*-1 - 90 + randf_range(-spread,spread)
		eb.can_split = false
	eb.global_position = $Gun/Muzzel.global_position


func shoot():
	can_attack = false
	if attack_type == "Single":
		spawn_bullet(0)
		attack_timer.start(randf_range(reload.x,reload.y))
	elif attack_type == "Auto":
		shots_left = randi_range(shots.x,shots.y)
		$Shot_delay.start(delay)
	elif attack_type == "Slime":
		animation.play("jump")
	elif attack_type == "Even":
		var shot = randi_range(shots.x, shots.y)
		var angle : float = -.5 * spread + (spread*.5/shot)
		for i in range(shot):
			spawn_bullet(angle)
			angle += spread/shot
		attack_timer.start(randf_range(reload.x,reload.y))
		shooot = false


func die():
	get_parent().alive_enemies -= 1
	player.enemies_killed += 1
	for i in range(0,randi_range(gold_drop.x,gold_drop.y)):
		var gd = gold.instantiate()
		get_parent().get_parent().add_child(gd)
		gd.global_position = Vector2(global_position.x,global_position.y+2)


func _on_attack_timer_timeout():
	can_attack = true


func _on_nav_timer_timeout():
	var dir = player.global_position - global_position
	raycast.target_position = player.global_position - raycast.global_position
	if !raycast.is_colliding():
		if dir.length() < run_dist:
			state = RUN
		elif dir.length() > approach_dist:
			state = APROACH
		else: 
			state = IDLE
	else:
		state = APROACH
	
	match state:
		APROACH:
			target_position = Vector2(player.global_position.x + randf_range(-10,10),player.global_position.y + randf_range(-10,10))
		IDLE:
			if !wander:
				target_position = global_position
				velocity = Vector2.ZERO
		RUN:
			target_position = global_position * 2 - player.global_position
	
	nav_agent.target_position = target_position


func _on_idle_timer_timeout():
	if !wander:
		wander = true
		if state == IDLE:
			target_position = Vector2(global_position.x + randi_range(-100,100),global_position.y + randi_range(-100,100))
		idle_timer.start(randf_range(2,3))
	else:
		wander = false
		idle_timer.start(randf_range(1,3))


func _on_collision_damage_area_entered(area):
	if area.is_in_group("Player_hitbox"):
		if player.dash.is_dashing() == false:
			player.current_health -= damage
			player.hit = true


func _on_shot_delay_timeout():
	if shots_left > 0 && !gold_spawned:
		spawn_bullet(0)
		shots_left -= 1
		$Shot_delay.start(delay)
	else:
		attack_timer.start(randf_range(reload.x,reload.y))


func _on_sound_finished():
	if gold_spawned:
		queue_free()
