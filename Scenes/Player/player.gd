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

var abiliites : Array[Ability]

var move_direction : Vector2 = Vector2.ZERO
var current_damage : float = 5
var rotation_speed : float = 10
var current_health : float = 5
var current_mana : float = 150
var current_dashes : float
var dash_duration : float = .15
var move_speed : float = 100
var dash_speed : float = 300
var max_health : float = 5
var max_dashes : float = 3
var max_mana : float = 150
var gold : int = 0

var mana_usage_bar_catchup : bool = false
var mana_regen_speed : float = .25
var dashes_used_catchup : bool = false
var damadged_bar_catchup : bool = false
var current_mana_usage : float
var current_dash_usage : float
var mana_regen : bool = false
var dash_regen : bool = false
var hit : bool = false

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
	var speed = dash_speed if dash.is_dashing() else move_speed
	move_direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	velocity = move_direction * speed  * delta
	position += velocity
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
	
	
	bar_management()
	weapon_rotate_to_mouse(get_global_mouse_position(),delta)
	move_and_slide()


func random_offset():
	return Vector2(randf_range(-shake_strength,shake_strength),randf_range(-shake_strength,shake_strength))


func weapon_rotate_to_mouse(target, delta):
	var direction = (target - weapon.global_position) #target global position if is an entity
	var angleTo = weapon.transform.x.angle_to(direction)
	weapon.rotation += (sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))
	weapon.b_rotation = weapon.rotation
	if direction.x > 0:
		sprite.flip_h = false
		weapon.get_child(0).scale.y = 1
	elif direction.x < 0:
		sprite.flip_h = true
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
	$ui/HLabel.text = str(health_bar.value)+"/"+str(max_health)
	$ui/MLabel.text = str(int(mana_bar.value))+"/"+str(max_mana)
	
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
		current_dashes += .02


func reset():
	Engine.time_scale = 1
	get_tree().paused = true
	gold = 0
	ability_inventory.abilities = []
	weapon.reset()
	current_health = max_health
	current_mana = max_mana
	for i in ability_inventory.abilities:
			i.quantity = 0
			ability_inventory.abilities.erase(i)
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
	move_speed = 100
	max_dashes = 3
	max_health = 5
	max_mana = 150
	mana_regen_speed = .25
	
	for ability in abiliites:
		if ability.ability_name == "Better Bullets":
			weapon.damage += ability.quantity
		elif ability.ability_name == "Bigger bullets":
			weapon.bullet_size *= 1 + .4*ability.quantity
			weapon.bullet_speed /=  1 + .4*ability.quantity
		elif ability.ability_name == "Double bullets":
			weapon.projectiles += ability.quantity
			weapon.bullet_spread += 5*ability.quantity
		elif ability.ability_name == "Faster bullets":
			weapon.bullet_speed *= 1 + .3*ability.quantity
		elif ability.ability_name == "Lucky":
			weapon.crit_chance += (10 * ability.quantity)
		elif ability.ability_name == "More mana":
			max_mana += 50 * ability.quantity
		elif ability.ability_name == "More health":
			max_health += ability.quantity
		elif ability.ability_name == "Faster receiver":
			weapon.fire_rate += ability.quantity
		elif ability.ability_name == "Metal jacket":
			weapon.piercing += ability.quantity
		elif ability.ability_name == "Scope":
			weapon.bullet_spread *= pow(.7,ability.quantity)
		elif ability.ability_name == "Mana regen":
			mana_regen_speed += ability.quantity*.25
		elif ability.ability_name == "TNT":
			weapon.explotion_size += .5 + (ability.quantity)*.5
		elif ability.ability_name == "Bouncy bullets":
			weapon.bounces += (ability.quantity)*2
		elif ability.ability_name == "Burger":
			max_health += 3
			move_speed *= .6
	
	for ability in abiliites:
		if ability.ability_name == "Box mag":
			weapon.full_auto = true
			weapon.damage *= .5
			weapon.fire_rate *= 2
		elif ability.ability_name == "Belt fed":
			weapon.damage *= .75
			weapon.fire_rate *= 2
		elif ability.ability_name == "Laser pointer":
			weapon.laser_pointer = true
			weapon.bullet_spread *= .5
		elif ability.ability_name == "Money shot":
			weapon.damage *= 2
			weapon.money_shot = true
	
	update_bar_values()


func update_bar_values():
	mana_bar.value = max_mana
	mana_bar.max_value = max_mana
	mana_bar.size.x = max_mana/3
	mana_usage_bar.value = max_mana
	mana_usage_bar.max_value = max_mana
	mana_usage_bar.size.x = max_mana/3
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
