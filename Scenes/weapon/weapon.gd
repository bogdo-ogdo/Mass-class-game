extends CharacterBody2D

signal mana_used

@export var bullet : PackedScene
@export var cooldown_timer : Timer
@export var weapon_machine : Node
@export var raycast : RayCast2D
@export var shot_interval : Timer
@export var sound : AudioStreamPlayer
@export var sprite : Sprite2D
@export var shake : Node2D

var b_rotation : float
var crit : bool

var current_damage : float

var chargeState : int = 0
var lastChargeState : int
var shake_strength : float
var chargeDamageMultiplier : float
var chargeDamage : float

var bullet_spread : float 
var bullet_type : String
var bullet_speed : float 
var bullet_size : float 
var crit_chance : float
var damage : float
var piercing : int
var bounces : int 
var explotion_size : float
var explotion_type : String
var charge : bool 

var fire_rate : float
var mana_cost : float
var flamethrow : bool
var projectiles : int
var full_auto : bool
var money_shot : bool
var laser_pointer : bool 

var projectiles_left : int = 0
var shooting : bool = false
var can_shoot : bool = true
var colliding : bool

var particles : bool = true


func _ready():
	raycast.add_exception(get_parent())
	update_weapon_parameters()
	UpdateWeaponCharge()

func _physics_process(_delta):
	var collider = raycast.get_collider()
	if collider is Node:
		if collider.is_in_group("dungeon"):
			colliding = true
		else:
			colliding = false
	else:
		colliding = false
		
	if laser_pointer:
		$Laser.visible = true
		$Laser.rotation = b_rotation
		$Laser.position = global_position
		$Laser.offset.x = 60 + $Muzzle.position.x
	else:
		$Laser.visible = false
	
	if shake_strength > 0:
		shake.position = random_offset()


func _on_player_shoot():
	chargeState = 0
	shake_strength = 0
	shake.position = Vector2.ZERO
	UpdateWeaponCharge()
	
	if money_shot:
		if get_parent().gold > 0 or get_parent().current_mana == get_parent().max_mana:
			shooting = true
			if can_shoot == true && colliding == false:
				cooldown_timer.start(1/fire_rate)
				can_shoot = false
				emit_signal("mana_used")
				if randi_range(0,100) <= crit_chance:
					crit = true
				else: 
					crit = false
				if !charge:
					if !flamethrow:
						get_parent().shake_strength = (weapon_machine.current_weapon.damage/5) * weapon_machine.current_weapon.projectiles + (weapon_machine.current_weapon.fire_rate/10)
					if projectiles == 1:
						spawn_bullet()
					else:
						shoot_projectiles()

	elif get_parent().current_mana > 0:
		shooting = true
		if can_shoot == true && colliding == false:
			cooldown_timer.start(1/fire_rate)
			can_shoot = false
			emit_signal("mana_used")
			if randi_range(0,100) <= crit_chance:
				crit = true
			else: 
				crit = false
			if !charge:
				if !flamethrow:
					get_parent().shake_strength = (weapon_machine.current_weapon.damage/5) * weapon_machine.current_weapon.projectiles + (weapon_machine.current_weapon.fire_rate/10)
				if projectiles == 1:
					spawn_bullet()
				else:
					shoot_projectiles()


func _on_player_shoot_stop():
	shooting = false
	if charge:
		lastChargeState = chargeState
		if !flamethrow:
			get_parent().shake_strength = (weapon_machine.current_weapon.damage/5) * weapon_machine.current_weapon.projectiles + (weapon_machine.current_weapon.fire_rate/10)
		if projectiles == 1:
			spawn_bullet()
		else:
			shoot_projectiles()
		chargeState = 0
		UpdateWeaponCharge()


func shoot_projectiles():
	projectiles_left = projectiles
	spawn_bullet()
	projectiles_left -= 1
	shot_interval.start(randf_range(.005,.01))


func spawn_bullet():
	if charge:
		current_damage = damage * (lastChargeState + 1) * chargeDamage
	else:
		current_damage = damage
	sound.stream = load(weapon_machine.current_weapon.sound)
	sound.play()
	var b = bullet.instantiate()
	owner.owner.add_child(b)
	b.anim_player.play(bullet_type)
	b.position = $Muzzle.global_position
	b.sprite.scale.y *= sprite.scale.y
	b.rotation = b_rotation
	b.crit = crit
	b.particles = particles
	get_parent().bullets_shot += 1


func reset():
	weapon_machine.current_weapon = weapon_machine.initial_weapon
	$Laser.visible = false
	update_weapon_parameters()


func update_weapon_parameters():
	bullet_type = weapon_machine.current_weapon.bullet_type
	full_auto = weapon_machine.current_weapon.full_auto
	damage = weapon_machine.current_weapon.damage
	bullet_speed = weapon_machine.current_weapon.bullet_speed * 100
	bullet_size = weapon_machine.current_weapon.bullet_size
	bullet_spread = weapon_machine.current_weapon.bullet_spread
	bullet_type = weapon_machine.current_weapon.bullet_type
	crit_chance = weapon_machine.current_weapon.crit_chance
	fire_rate = weapon_machine.current_weapon.fire_rate
	mana_cost = weapon_machine.current_weapon.mana_cost
	full_auto = weapon_machine.current_weapon.full_auto
	projectiles = weapon_machine.current_weapon.projectiles
	piercing = weapon_machine.current_weapon.piercing
	bounces = weapon_machine.current_weapon.bounces
	explotion_size = weapon_machine.current_weapon.explotion_size
	explotion_type = weapon_machine.current_weapon.explotion_type
	money_shot = weapon_machine.current_weapon.money_shot
	flamethrow = weapon_machine.current_weapon.flamethrow
	charge = weapon_machine.current_weapon.charge
	chargeDamage = weapon_machine.current_weapon.chargeDamage
	
	cooldown_timer.wait_time = 1/fire_rate


func UpdateWeaponCharge():
	if chargeState == 0:
		sprite.material.set_shader_parameter("progress", 1)
		shake_strength = 0
	elif chargeState == 1:
		sprite.material.set_shader_parameter("progress", .6)
		shake_strength = 1
	elif chargeState == 2:
		sprite.material.set_shader_parameter("progress", .3)
		shake_strength = 2
	elif chargeState == 3:
		sprite.material.set_shader_parameter("progress", 0)
		shake_strength = 3


func random_offset():
		return Vector2(randf_range(-shake_strength,shake_strength),randf_range(-shake_strength,shake_strength))


func _on_cooldown_timeout():
	can_shoot = true
	if charge:
		if (shooting):
			if chargeState < 3:
				chargeState += 1
			UpdateWeaponCharge()
			if full_auto && chargeState == 3:
				lastChargeState = chargeState
				if !flamethrow:
					get_parent().shake_strength = (weapon_machine.current_weapon.damage/5) * weapon_machine.current_weapon.projectiles + (weapon_machine.current_weapon.fire_rate/10)
				if projectiles == 1:
					spawn_bullet()
				else:
					shoot_projectiles()
				
				_on_player_shoot()
			else:
				cooldown_timer.start(1/fire_rate)
	elif full_auto == true && shooting == true:
		_on_player_shoot()

func _on_shot_interval_timeout():
	if projectiles_left > 0:
		spawn_bullet()
		projectiles_left -= 1
		shot_interval.start(randf_range(.005,.01))
