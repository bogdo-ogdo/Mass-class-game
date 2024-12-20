extends CharacterBody2D

signal shoot
signal shoot_stop
signal restart_game

@onready var you_died = $ui/You_died
@onready var dash_bar = $ui/Dash_bar
@onready var dash_usage_bar = $ui/Dash_bar/Dash_usage_bar
@onready var dash_usage_timer = $Dash_usage
@onready var dash_regen_timer = $Dash_regen

@onready var gc = $ui/You_died/You_died/VBoxContainer/HBoxContainer/VBoxContainer2/GC
@onready var ek = $ui/You_died/You_died/VBoxContainer/HBoxContainer/VBoxContainer2/EK
@onready var mu = $ui/You_died/You_died/VBoxContainer/HBoxContainer/VBoxContainer2/MU
@onready var bs = $ui/You_died/You_died/VBoxContainer/HBoxContainer/VBoxContainer2/BS
@onready var dt = $ui/You_died/You_died/VBoxContainer/HBoxContainer/VBoxContainer2/DT
@onready var dd = $ui/You_died/You_died/VBoxContainer/HBoxContainer/VBoxContainer2/DD
@onready var du = $ui/You_died/You_died/VBoxContainer/HBoxContainer/VBoxContainer2/DU

@export var anim_player : AnimationPlayer
@export var sprite : Sprite2D
@export var tile_map : TileMap
@export var weapon : CharacterBody2D
@export var dungeon : Node2D
@export var health_bar : TextureProgressBar
@export var damaged_bar : TextureProgressBar
@export var mana_bar : TextureProgressBar
@export var mana_usage_bar : TextureProgressBar
@export var damaged_timer : Timer
@export var mana_usage_timer : Timer
@export var mana_regen_timer : Timer
@export var camera : Camera2D
@export var ui_sprite : Sprite2D
@export var ui_anim_player : AnimationPlayer
@export var low_health_indicator : Sprite2D
@export var gold_lable : Label
@export var ability_inventory : Ability_Inventory
@export var dash : Node2D
@export var change_pitch : bool
@export var shop : Control
@export var distortionShader : ColorRect

var abiliites : Array[Ability]

var move_direction : Vector2 = Vector2.ZERO
var current_damage : float = 5
var rotation_speed : float = 10
var current_health : float = 5
var current_mana : float = 150
var current_dashes : float
var dash_duration : float = .15
var dash_regen_speed : float = 0.02
var move_speed : float = 5
var dash_speed : float = 300
var max_health : float = 5
var max_dashes : float = 3
var max_mana : float = 150
var gold : int = 0

var drunkness : float = 0
var highvalue : float = 0

var health_regen_speed : float = 10
var health_regenrating = false
var gates_closed : bool = true
var mana_usage_bar_catchup : bool = false
var mana_regen_speed : float = .25
var dashes_used_catchup : bool = false
var damadged_bar_catchup : bool = false
var current_mana_usage : float
var current_dash_usage : float
var mana_regen : bool = false
var dash_regen : bool = false
var hit : bool = false
var electricity : bool = false

var shake_strength : float = 0.0
var shake_fade : float = 5.0

var gold_collected : int = 0
var enemies_killed : int = 0
var damage_done : float = 0
var mana_used : float = 0
var damage_taken : float = 0
var dashes_used : int = 0
var bullets_shot : int = 0

var win : bool = false

var speed = 0
var MAX_SPEED = 100
var car = false
var wheel_base = 17
var steering_angle = 100
var engine_power = 25
var friction = -10
var drag = -0.01
var braking = -25
var max_speed_reverse = 50
var slip_speed = 100
var traction_fast = 1
var traction_slow = 10
var acceleration = Vector2.ZERO
var steer_direction
var auto_aim = false
var enemy_target : Node2D = null
var enemies_in_area = []

func _ready():
	ui_sprite.hide()
	mana_bar.value = max_mana
	mana_bar.max_value = max_mana
	mana_usage_bar.value = max_mana
	mana_usage_bar.max_value = max_mana
	current_mana = max_mana
	
	health_bar.value = max_health
	health_bar.max_value = max_health 
	damaged_bar.value = max_health
	damaged_bar.max_value = max_health
	current_health = max_health
	
	dash_bar.value = max_dashes
	dash_bar.max_value = max_dashes
	dash_usage_bar.value = max_dashes
	dash_usage_bar.max_value = max_dashes
	current_dashes = max_dashes
	_on_dungeon_clear_floor()
	you_died.visible = false
	you_died.modulate.a = 0


func _physics_process(delta):
	if not car:
		move_direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
		if dash.is_dashing() and move_direction != Vector2.ZERO:
			speed = dash_speed
		elif dash.is_dashing():
			speed = dash_speed
			move_direction = (get_global_mouse_position()-position).normalized()
		elif move_direction == Vector2.ZERO:
			speed = 0
		elif speed != MAX_SPEED:
			speed += move_speed
		if speed >= MAX_SPEED and not dash.is_dashing():
			speed = MAX_SPEED
		velocity = move_direction * speed  * delta
		position += velocity
	else:
		if dash.is_dashing():
			acceleration = Vector2.ZERO
			get_input()
			apply_friction(delta)
			calculate_steering(delta)
			wheel_base = 9
			velocity += 20 * acceleration * delta
		else:
			acceleration = Vector2.ZERO
			get_input()
			apply_friction(delta)
			calculate_steering(delta)
			wheel_base = 17
			velocity += acceleration * delta
			move_and_slide()
	if move_direction != Vector2.ZERO:
		anim_player.play("gob_run")
	else:
		anim_player.play("gob_idle")
	
	if current_health <= 0 or win:
		get_parent().music.playing = false
		shake_strength = 0
		if Engine.time_scale > 0:
			Engine.time_scale -= .02
		if !you_died.visible:
			gc.text = ": "+ str(int(gold_collected))
			ek.text = ": "+ str(int(enemies_killed))
			mu.text = ": "+ str(int(mana_used))
			bs.text = ": "+ str(int(bullets_shot))
			dt.text = ": "+ str(int(damage_taken))
			dd.text = ": "+ str(int(damage_done))
			du.text = ": "+ str(int(dashes_used))
		you_died.visible = true
		if win:
			$ui/You_died/You_died/VBoxContainer/You_x.text = "You won"
			$ui/You_died/You_died/VBoxContainer/You_x.self_modulate = Color(.1,1,.1)
		else:
			$ui/You_died/You_died/VBoxContainer/You_x.text = "You died"
			$ui/You_died/You_died/VBoxContainer/You_x.self_modulate = Color(1,.1,.1)
			if !$Sounds/Death.playing:
				$Sounds/Death.play()
		if you_died.modulate.a < .6:
			you_died.modulate.a += .01
	
	low_health_indicator.modulate.a = 1 - (current_health*3/max_health)
	
	gold_lable.text = str(gold)
	
	if hit == true:
		ui_sprite.show()
		ui_anim_player.play("Player_hit")
		hit = false
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
		camera.offset = random_offset()
	
	if auto_aim:
		if enemies_in_area != []:
			var closest : Node2D = enemies_in_area[0]
			for i in enemies_in_area:
				if abs(global_position - i.global_position) < abs(global_position - closest.global_position):
					closest = i
			weapon_rotate_to_mouse(closest.global_position,delta)
		else:
			weapon_rotate_to_mouse(get_global_mouse_position(),delta)
	else:
		weapon_rotate_to_mouse(get_global_mouse_position(),delta)
	bar_management()
	move_and_slide()


func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func get_input():
	var turn = Input.get_axis("ui_left", "ui_right")
	steer_direction = turn * deg_to_rad(steering_angle-10)
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking


func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * velocity.length()
# velocity = new_heading * velocity.length()
	rotation = new_heading.angle()

func random_offset():
	return Vector2(randf_range(-shake_strength,shake_strength),randf_range(-shake_strength,shake_strength))


func weapon_rotate_to_mouse(target, delta):
	var direction = (target - weapon.global_position) #target global position if is an entity
	var angleTo = weapon.transform.x.angle_to(direction)
	weapon.rotation += (sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))
	weapon.b_rotation = weapon.rotation
	if direction.x > 0:
		if not car:
			sprite.scale.x = 1
		weapon.get_child(0).scale.y = 1
	elif direction.x < 0:
		if not car:
			sprite.scale.x = -1
		weapon.get_child(0).scale.y = -1
	weapon.rotation_degrees = round_to_dec(weapon.rotation_degrees,-1)


func _input(event):
	if event.is_action_pressed("ui_shoot"):
		emit_signal("shoot")
	if event.is_action_released("ui_shoot"):
		emit_signal("shoot_stop")
	if event.is_action("ui_accept") && dash.can_dash && !dash.is_dashing():
		if current_dashes >= 1:
			dash.start_dash(sprite, dash_duration)
			current_dashes -= 1
			dashes_used += 1


func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func _on_damage_recieved(damage : float) -> void:
	current_health -= damage


func bar_management():
	mana_bar.value = current_mana
	mana_usage_bar.value = current_mana_usage
	health_bar.value = current_health
	damaged_bar.value = current_damage
	dash_bar.value = current_dashes
	dash_usage_bar.value = current_dash_usage
	gates_closed = dungeon.gates_up
	$ui/HLabel.text = str(health_bar.value)+"/"+str(max_health)
	$ui/MLabel.text = str(int(mana_bar.value))+"/"+str(max_mana)
	
	# Health Regenration
	if health_regenrating == false and gates_closed == true and current_health < max_health:
		health_regenrating = true
		$Health_regen.start(health_regen_speed)
	
	if current_mana_usage < current_mana:
		current_mana_usage = current_mana
		mana_usage_bar_catchup = false
	if current_mana_usage > current_mana && mana_usage_bar_catchup == false && weapon.shooting == true:
		mana_usage_timer.start()
		mana_regen_timer.stop()
		mana_regen = false
	elif current_mana_usage > current_mana && mana_usage_bar_catchup == true:
		if weapon.shooting == false && weapon.full_auto == true:
			current_mana_usage -= mana_regen_speed*4
		elif weapon.shooting == true && weapon.full_auto == false:
			mana_usage_timer.start()
			mana_regen_timer.stop()
			mana_usage_bar_catchup = false
			mana_regen = false
		elif weapon.shooting == false && weapon.full_auto == false:
			current_mana_usage -= mana_regen_speed*4
	elif current_mana_usage <= current_mana:
		mana_usage_bar_catchup = false
		if mana_regen_timer.is_stopped():
			mana_regen_timer.start(1/(mana_regen_speed*2))
	
	if current_dash_usage < current_dashes:
		current_dash_usage = current_dashes
		dashes_used_catchup = false
	if current_dash_usage > current_dashes && dashes_used_catchup == false && dash.is_dashing():
		dash_usage_timer.start()
		dash_regen_timer.stop()
		dash_regen = false
	elif current_dash_usage > current_dashes && dashes_used_catchup == true:
		if !dash.is_dashing():
			current_dash_usage -= .1
		elif dash.is_dashing():
			dash_usage_timer.start()
			dash_regen_timer.stop()
			dashes_used_catchup = false
			dash_regen = false
	elif current_dash_usage <= current_dashes:
		dashes_used_catchup = false
		if dash_regen_timer.is_stopped():
			dash_regen_timer.start()
	
	if current_damage <= current_health:
		current_damage = current_health
		damadged_bar_catchup = false
	elif current_damage > current_health && damadged_bar_catchup == false:
		if damaged_timer.is_stopped():
			damaged_timer.start(2)
	elif current_damage > current_health && damadged_bar_catchup == true:
		current_damage -= .02
		
	if current_mana > max_mana:
		mana_regen = false
		current_mana = max_mana
	if mana_regen:
		current_mana += mana_regen_speed
	
	if current_dashes > max_dashes:
		dash_regen = false
		current_dashes = max_dashes
	if dash_regen:
		current_dashes += dash_regen_speed


func reset():
	rotation = 0
	Engine.time_scale = 1
	get_tree().paused = true
	gold = 0
	weapon.reset()
	current_health = max_health
	current_mana = max_mana
	for i in ability_inventory.abilities:
			i.quantity = 0
			ability_inventory.abilities.erase(i)
	for i in abiliites:
			i.quantity = 0
			abiliites.erase(i)
	ability_inventory.abilities = []
	abiliites = []
	update_abilities()
	shop.reset()
	$Dust.color = Color(.78,.78,.78)
	you_died.modulate.a = 0
	win = false
	gold_collected  = 0
	enemies_killed  = 0
	damage_done  = 0
	mana_used  = 0
	damage_taken  = 0
	dashes_used  = 0
	bullets_shot  = 0


func _on_mana_regen_timeout():
	mana_regen = true


func _on_mana_usage_timeout():
	mana_usage_bar_catchup = true


func _on_damaged_timeout():
	damadged_bar_catchup = true


func _on_weapon_mana_used():
	if !weapon.money_shot:
		current_mana -= weapon.mana_cost
		mana_used += weapon.mana_cost
	else:
		if gold > 0:
			gold -= 1
		else:
			current_mana = 0
			
	mana_regen = false


func _on_restart_pressed():
	emit_signal("restart_game")
	you_died.visible = false
	get_parent().start_menu.open()
	if win:
		get_parent().credits.open()
	reset()


func _on_dash_usage_timeout():
	dashes_used_catchup = true


func _on_dash_regen_timeout():
	dash_regen = true


func update_abilities():
#elif ability.ability_name == "":
	var is_new : bool
	abiliites = []
	for ability in ability_inventory.abilities:
		is_new = true
		for i in abiliites:
			if i == ability:
				is_new = false
		if is_new:
			abiliites.push_back(ability)
	
	weapon.update_weapon_parameters()
	
	weapon.laser_pointer = false
	MAX_SPEED = 100
	dash_duration = .15
	dash_regen_speed = 0.02
	move_speed = 5
	max_dashes = 3
	max_health = 5
	max_mana = 150
	mana_regen_speed = .25
	highvalue = 0
	drunkness = 0
	dash_regen_timer.wait_time = 2
	car = false
	electricity = false
	auto_aim = false
	
	for ability in abiliites:
		#elif ability.ability_name == "":
		if ability.ability_name == "Better Bullets":
			weapon.damage += ability.quantity
		elif ability.ability_name == "Face Mask":
			max_health += ability.quantity
		elif ability.ability_name == "Weed":
			weapon.piercing += ability.quantity
			weapon.crit_chance += ability.quantity * 10
			highvalue += ability.quantity
			drunkness += ability.quantity * .1
		elif ability.ability_name == "THE JUICE":
			var x = randi_range(1,5)
			if x == 1:
				weapon.damage += 10 * ability.quantity
			elif x == 2:
				max_health += 10 * ability.quantity
			elif x == 3:
				max_mana += 400 * ability.quantity
				mana_regen_speed *= 3
			elif x == 4:
				dash_duration += .25 * ability.quantity
				dash_regen_speed += .05 * ability.quantity
				dash_regen_timer.wait_time *= 0.5
			elif x == 5:
				highvalue += 4 * ability.quantity
				drunkness += 4 * ability.quantity
		elif ability.ability_name == "Alice wonderland":
			max_health += ability.quantity * 2 
			weapon.damage += ability.quantity * 1
		elif ability.ability_name == "Roid Rage":
			weapon.damage += ability.quantity
		elif ability.ability_name == "Cold one":
			drunkness += ability.quantity
		elif ability.ability_name == "Blood of the youth":
			max_mana += 50 * ability.quantity
			max_health -= ability.quantity
		elif ability.ability_name == "Speed":
			highvalue += ability.quantity
			drunkness += ability.quantity * .2
		elif ability.ability_name == "THE THINGS UNDER THE BED":
			weapon.damage += 50 * ability.quantity
			var teddyBear = false
			for i in abiliites:
				if i.ability_name == "Teddy bear":
					teddyBear = true
			if !teddyBear:
				max_health -= 1000
		elif ability.ability_name == "Vodka":
			weapon.damage += 2 * ability.quantity
			max_health += 3 * ability.quantity
		elif ability.ability_name == "Cigarettes":
			weapon.damage += ability.quantity



	for ability in abiliites:
		if ability.ability_name == "Box mag":
			weapon.full_auto = true
			weapon.damage *= .5
			weapon.fire_rate *= 2
		elif ability.ability_name == "Belt fed":
			weapon.damage *= .75
			weapon.fire_rate *= 2
		elif ability.ability_name == "Dash Cooldown":
			dash_regen_timer.wait_time *= pow(0.5, ability.quantity)
			dash_regen_speed *= 1 + 1 * ability.quantity
		elif ability.ability_name == "Laser pointer":
			weapon.laser_pointer = true
			weapon.bullet_spread *= .5
		elif ability.ability_name == "Money shot":
			weapon.damage *= 2
			weapon.money_shot = true
		elif ability.ability_name == "Roid Rage":
			weapon.bullet_speed *= 1 + .3 * ability.quantity
		elif ability.ability_name == "Cold one":
			max_health *= 1 + .25 * ability.quantity
			move_speed *= 1 - .1 * ability.quantity
		elif ability.ability_name == "Blood of the youth":
			mana_regen_speed *= 1 + .5 * ability.quantity
		elif ability.ability_name == "Car":
			car = true
			weapon.damage *= 2 * ability.quantity
		elif ability.ability_name == "Tin foil hat":
			electricity = true
		elif ability.ability_name == "Cocaine":
			dash_regen_timer.wait_time *= 0.5
			dash_duration *= 1 + .5 * ability.quantity
		elif ability.ability_name == "Third eye":
			auto_aim = true
			weapon.bullet_spread *= 0.1
		elif ability.ability_name == "Speed":
			move_speed *= 1 + .35 * ability.quantity
			MAX_SPEED *= 1 + .35 * ability.quantity
		elif ability.ability_name == "Vodka":
			weapon.bullet_spread *= 1 + .3 * ability.quantity
		elif ability.ability_name == "Cigarettes":
			drunkness *= pow(.7, ability.quantity)
			highvalue *= pow(.7, ability.quantity)

			
	if max_health < 1:
		max_health == 1
			
	
	update_bar_values()
	update_effects()


func update_bar_values():
	mana_bar.value = max_mana
	mana_bar.max_value = max_mana
	mana_bar.size.x = max_mana/1.5
	mana_usage_bar.value = max_mana
	mana_usage_bar.max_value = max_mana
	mana_usage_bar.size.x = max_mana/1.5
	current_mana = max_mana
	
	#health_bar.value = max_health
	health_bar.max_value = max_health 
	health_bar.size.x = max_health*10
	#damaged_bar.value = max_health
	damaged_bar.max_value = max_health
	damaged_bar.size.x = health_bar.size.x
	#current_health = max_health
	
	dash_bar.value = max_dashes
	dash_bar.max_value = max_dashes
	dash_usage_bar.value = max_dashes
	dash_usage_bar.max_value = max_dashes
	current_dashes = max_dashes


func update_effects():
	distortionShader.material.set_shader_parameter("distortion_strength", drunkness * .005)
	distortionShader.material.set_shader_parameter("offset", highvalue)
	$Electricity.set_active(electricity)


func _on_footsteps_finished():
	$Sounds/footsteps.pitch_scale = 1 + randf_range(-.5,.5)


func _on_dungeon_clear_floor():
	if get_parent().level == 1:
		$Dust.color = Color(.78,.78,.78)
	elif get_parent().level == 2:
		$Dust.color = Color(.53,.89,.45)
	elif get_parent().level == 3:
		$Dust.color = Color(.78,.78,.78)
	elif get_parent().level == 4:
		$Dust.color = Color(.78,.78,.78)


func _on_audio_stream_player_finished():
	$Sounds/Music.playing = true


func _on_health_regen_timeout() -> void:
	if current_health < max_health:
		current_health += 1
	health_regenrating = false
	bar_management()

func _on_auto_aim_area_entered(area: Node2D) -> void:
	if area.is_in_group("Enemy"):
		enemies_in_area.append(area)


func _on_auto_aim_area_exited(area: Node2D) -> void:
	if area.is_in_group("Enemy"):
		enemies_in_area.erase(area)
