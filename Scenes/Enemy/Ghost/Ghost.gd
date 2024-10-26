extends CharacterBody2D


signal player_damage

@onready var gold : PackedScene = preload("res://Scenes/Treasure/gold.tscn")
@onready var die_sound = preload("res://audio/Enemy/male-scream-in-fear-123079.mp3")
@onready var alt_animation : AnimationPlayer = $hit_AnimationPlayer
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var attack_timer : Timer = $Attack_timer
@onready var idle_timer : Timer = $Idle_timer
@onready var raycast : RayCast2D = $RayCast2D
@onready var nav_timer : Timer = $Nav_timer
@onready var sprite : Sprite2D = $Sprite2D
@onready var damage_collider : Area2D = $collision_damage/CollisionShape2D
@export var approach_dist : float
@export var run_dist : float 
@export var gold_drop : Vector2
@export var move_speed : float 
@export var health : float 
@export var damage : float
@export var rarity : int
@export var reload : Vector2
@export var flip_h : bool
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
var on_top : bool = false

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
	attack_timer.start(randf_range(5,20))
	y_sort_enabled = true
	damage_collider.disabled = true
	visible = false
	z_index = 1
	$Hit.energy = 0
	$sound.pitch_scale = randf_range(.75,1.4)


func _physics_process(delta: float) -> void:
	if spawn == true:
		spawn_value -= .015
		sprite.material.set_shader_parameter("progress", spawn_value)
		can_move = false
		velocity = Vector2.ZERO
		if spawn_value <= 0:
			spawn = false
			can_move = true
			attack_timer.start(randf_range(1,reload.y))
	
	if health <= 0:
		if !gold_spawned:
			die()
			$sound.stream = die_sound
			$sound.play()
			gold_spawned = true
		spawn_value += .02
		velocity = Vector2.ZERO
		sprite.material.set_shader_parameter("progress", spawn_value)
		$collision_damage.monitoring = false
		$Area2D.monitorable = false
		can_attack = false
	
	if can_attack == true:
			damage_collider.disabled = true
			visible = false
			state = APROACH
			on_top = true
	
	
	
	if velocity.length() < 2:
		if !animation.current_animation == "jump":
			animation.play("p_idle")
	else:
		if !animation.current_animation == "jump":
			animation.play("p_run")
	
	if hit == true:
		alt_animation.play("hit")
		hit = false

	if on_top:
		pass
	else:
		if can_move && !raycast.is_colliding():
			var direction = (nav_agent.get_next_path_position() - global_position).normalized()
			var steering = ((direction * move_speed) - velocity) * delta * 1.2
			velocity += steering
		elif raycast.is_colliding():
			velocity = (nav_agent.get_next_path_position() - global_position).normalized() * move_speed/2
		else:
			velocity = Vector2.ZERO
		move_and_slide()



func round_to_dec(num, digit):
	return round(num * pow(15.0, digit)) / pow(15.0, digit)


func die():
	get_parent().alive_enemies -= 1
	player.enemies_killed += 1
	for i in range(0,randi_range(gold_drop.x,gold_drop.y)):
		var gd = gold.instantiate()
		get_parent().get_parent().add_child(gd)
		gd.global_position = Vector2(global_position.x,global_position.y+2)


func _on_attack_timer_timeout():
	can_attack = true
	visible = true


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


func _on_sound_finished():
	if gold_spawned:
		queue_free()
