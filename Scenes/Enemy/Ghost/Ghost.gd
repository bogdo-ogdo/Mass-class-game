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
@onready var damage_collider : CollisionShape2D = $collision_damage/CollisionShape2D
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
var waiting : bool = true

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
	attack_timer.start(randf_range(1,2))
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
			visible = true
			state = APROACH

	
	
	if hit == true:
		alt_animation.play("hit")
		hit = false

	if waiting:
		pass
	elif on_top:
		global_position = player.global_position
		velocity = Vector2(0,0)
		print(position)
	else:
		velocity = (player.global_position - global_position).normalized()*move_speed
		move_and_slide()

	if velocity.length() < 2:
		if !animation.current_animation == "jump":
			animation.play("p_idle")
	else:
		if !animation.current_animation == "jump":
			animation.play("p_run")
	


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
	idle_timer.start(3)
	waiting = false
	on_top = true

func _on_idle_timer_timeout():
	nav_timer.start(0.5)
	waiting = true
	on_top=false


func _on_collision_damage_area_entered(area):
	if area.is_in_group("Player_hitbox"):
		if player.dash.is_dashing() == false:
			player.current_health -= damage
			player.hit = true


func _on_sound_finished():
	if gold_spawned:
		queue_free()


func _on_nav_timer_timeout() -> void:
	waiting = false
	damage_collider.disabled = false
	modulate.a = 1.0
	pass # Replace with function body.
