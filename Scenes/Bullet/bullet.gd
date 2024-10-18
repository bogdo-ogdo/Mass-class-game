extends CharacterBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var weapon : CharacterBody2D = get_tree().get_first_node_in_group("Player").get_child(4)
@onready var blood_splat = preload("res://Scenes/Effects/Blood_splat.tscn")
@onready var explosion = preload("res://Scenes/Bullet/explosion.tscn")

var damage : float 
var speed : float = 0
var crit_chance : float  
var size : float
var spread : float
var piercing : int
var bounces : int
var flamethrow : bool
var rotated : bool = false
var can_move : bool = true
var fire : bool = false
var explotion_size : float 
var explotion_type : String
var expd : bool = false
var explotion_damage : float
var stop : bool = false
var bounce
var ff : bool = true
var particles : bool = true

var v : Vector2

var crit : bool

func _ready():
	$Sprite2D.visible = false
	weapon = get_tree().get_first_node_in_group("Player").get_child(4)
	damage = weapon.damage
	crit_chance = weapon.crit_chance
	size = weapon.bullet_size
	spread = weapon.bullet_spread
	piercing = weapon.piercing
	bounces = weapon.bounces
	flamethrow = weapon.flamethrow
	explotion_size = weapon.explotion_size
	explotion_type = weapon.explotion_type
	explotion_damage = damage
	if expd: 
		damage = 0


func _physics_process(_delta):
	if ff:
		rotation_degrees += randf_range(-spread,spread)
		v = Vector2.RIGHT.rotated(deg_to_rad(rotation_degrees))*(weapon.bullet_speed/200)
		ff = false
	else:
		$Area2D.monitoring = true
	$Sprite2D.visible = true
	if can_move:
		if flamethrow == true && size < 5:
			size += .03
			speed -= .1
				
		scale = Vector2(size,size)/3
		z_index = 1
		velocity = v
	if crit:
		modulate.r = 5
		modulate.b = .2
		modulate.g = .2
		damage *= 2
		crit = false
	if expd:
		explode()
		expd = false
	if stop:
		queue_free()
	
	var collision_info = move_and_collide(velocity)
	if collision_info:
		v = velocity.bounce(collision_info.get_normal())
		rotation = v.angle()
		if bounces == 0:
			if explotion_size > 0:
				explode()
			queue_free()
		else:
			bounces -= 1
			if explotion_size > 0:
				explode()


func explode():
	var ex = explosion.instantiate()
	get_parent().add_child(ex)
	ex.size = explotion_size
	ex.damage = explotion_damage 
	ex.type = explotion_type
	ex.global_position = global_position


func splat():
	var bd = blood_splat.instantiate()
	get_parent().add_child(bd)
	bd.transform = transform
	bd.scale = Vector2(.4,.4)


func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemy"):
		if piercing > 0:
			piercing -= 1
			if explotion_size > 0:
				expd = true
			else:
				area.get_parent().health -= damage
				weapon.get_parent().damage_done += damage
				area.get_parent().hit = true
				if particles:
					splat()
		else:
			if explotion_size > 0:
				expd = true
				stop = true
			else:
				area.get_parent().health -= damage
				weapon.get_parent().damage_done += damage
				area.get_parent().hit = true
				if particles:
					splat()
				queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered():
	$Sprite2D.visible = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	$Sprite2D.visible = true
