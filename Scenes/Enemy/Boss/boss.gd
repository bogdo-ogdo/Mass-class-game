extends CharacterBody2D

signal player_damage

@onready var enemy_bullet : PackedScene = preload("res://Scenes/Enemy/Peasant/enemy_bullet.tscn")
@onready var gold : PackedScene = preload("res://Scenes/Treasure/gold.tscn")
@onready var alt_animation : AnimationPlayer = $hit_AnimationPlayer
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var attack_timer : Timer = $attackTimer
@onready var idle_timer : Timer = $idleTimer
@onready var nav_timer : Timer = $navTimer
@onready var delay_timer : Timer = $delayTimer
@onready var sprite : Sprite2D = $Sprite2D
@onready var gun : Sprite2D = $MiniGun
@onready var damaged_timer : Timer = $damageTimer

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
@export var Ashots : Vector2

var spawn_value : float
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
var current_attack : String
var current_health : float
var attacks : Array = ["Circle","Auto","Split"]
var half = false
var split : bool = false
var aproach : bool = false
var b_scale : float
var b_speed : float

var damaged : float 
var damadged_bar_catchup : bool = false

enum {
	APROACH,
	IDLE,
	RUN,
}

enum {
	BEAM,
	CICLE,
	AUTO,
	SPAWN,
}

var state = IDLE


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	can_move = false
	spawn = true
	spawn_value = 1
	sprite.material.set_shader_parameter("progress", spawn_value)
	gun.material.set_shader_parameter("progress", spawn_value)
	y_sort_enabled = true
	z_index = 1
	


func _physics_process(delta: float) -> void:
	if spawn == true:
		spawn_value -= .015
		$CanvasLayer/Boss_bar.modulate.a += .015
		sprite.material.set_shader_parameter("progress", spawn_value)
		gun.material.set_shader_parameter("progress", spawn_value)
		can_move = false
		velocity = Vector2.ZERO
		if spawn_value <= 0:
			spawn = false
			can_move = true
			attack_timer.start(randf_range(1,reload.y))
	
	if health <= 0:
		velocity = Vector2.ZERO
		$CanvasLayer/Boss_bar.modulate.a += .05
		spawn_value += .05
		sprite.material.set_shader_parameter("progress", spawn_value)
		gun.material.set_shader_parameter("progress", spawn_value)
		$Collision_damage.monitoring = false
		$Hitbox.monitorable = false
		can_attack = false
		if spawn_value >= 1:
			die()
		
	if can_attack:
		current_attack = attacks.pick_random()
		if current_attack == "Circle":
			attack_type = "Even"
			spread = 360
			shots = Vector2(20,30)
			Ashots = Vector2(3,5)
			split = false
			aproach = true
			delay = .75
			b_scale = 1
			b_speed = 1
		elif current_attack == "Auto":
			attack_type = "Auto"
			spread = 30
			shots = Vector2(1,1)
			Ashots = Vector2(60,90)
			split = false
			delay = .1
			b_scale = 1
			aproach = true
			b_speed = 1.6
		elif current_attack == "Split":
			attack_type = "Even"
			spread = 360
			shots = Vector2(8,8)
			Ashots = Vector2(1,3)
			split = true
			delay = .75
			b_scale = 1.5
			b_speed = .75
		shoot()
	
	if velocity.length() < 2:
		animation.play("idle")
	else:
		animation.play("run")
	
	if hit == true:
		alt_animation.play("hit")
		hit = false
		damadged_bar_catchup = false
	
	if can_move:
		var direction = (nav_agent.get_next_path_position() - global_position).normalized()
		var steering = ((direction * move_speed) - velocity) * delta * 1.2
		velocity += steering
	else:
		velocity = Vector2.ZERO
	
	update_bar()
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
	$Gunshot.play()
	var eb = enemy_bullet.instantiate()
	get_parent().get_parent().add_child(eb)
	var direction = global_position - player.global_position
	eb.scale *= b_scale
	eb.speed *= b_speed
	if attack_type == "Even":
		eb.rotation_degrees = angle + gun.rotation_degrees
	else:
		eb.rotation_degrees = rad_to_deg(atan2(direction.x,direction.y))*-1 - 90 + randf_range(-spread,spread)
	eb.global_position = $MiniGun/Muzzle.global_position
	eb.can_split = split


func shoot():
	can_attack = false
	if attack_type == "Single":
		spawn_bullet(0)
		attack_timer.start(randf_range(reload.x,reload.y))
	elif attack_type == "Auto":
		shots_left = randi_range(Ashots.x,Ashots.y)
		delay_timer.start(delay)
	elif attack_type == "Even":
		shots_left = randi_range(Ashots.x,Ashots.y)
		delay_timer.start(delay)


func die():
	get_parent().alive_enemies -= 1
	for i in range(0,randi_range(gold_drop.x,gold_drop.y)):
		var gd = gold.instantiate()
		get_parent().get_parent().add_child(gd)
		gd.global_position = Vector2(global_position.x,global_position.y+2)
	queue_free()


func _on_attack_timer_timeout():
	can_attack = true


func _on_nav_timer_timeout():
	var dir = player.global_position - global_position
	if dir.length() < run_dist:
		state = RUN
	elif dir.length() > approach_dist:
		state = APROACH
	else: 
		state = IDLE
	
	if aproach:
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
			player.current_health -= 1
			player.hit = true


func update_bar():
	$CanvasLayer/Boss_bar.value = health
	$CanvasLayer/Boss_bar/damage_bar.value = damaged
	if damaged <= health:
		damaged = health
		damadged_bar_catchup = false
	elif damaged > health && !damadged_bar_catchup:
		if damaged_timer.is_stopped():
			damaged_timer.start(1)
	elif damaged > health && damadged_bar_catchup == true:
		damaged -= 2


func _on_delay_timer_timeout():
	if shots_left > 0:
		if attack_type == "Auto":
			spawn_bullet(0)
		elif attack_type == "Even":
			var shot = randi_range(shots.x, shots.y)
			var angle : float = -.5 * spread + (spread*.5/shot)
			for i in range(shot):
				spawn_bullet(angle)
				angle += spread/shot
		shots_left -= 1
		delay_timer.start(delay)
	else:
		attack_timer.start(randf_range(reload.x,reload.y))
		aproach = false


func _on_damage_timer_timeout():
	damadged_bar_catchup = true
