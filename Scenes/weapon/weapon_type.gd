extends Node
class_name weapon_type
signal Transitioned

@export var anim_player : AnimationPlayer

var first_update : bool = true

var full_auto : bool = false
var flamethrow : bool = false
var water : bool = false
var money_shot : bool = false
var bullet_type : String

var damage : float
var fire_rate : float
var mana_cost : float
var crit_chance : float
var bullet_size : float
var bullet_speed : float
var bullet_spread : float
var projectiles : int = 1
var piercing : int = 0
var bounces : int = 0
var explotion_size : float = 0
var explotion_type : String = "Explosion"
var txture : String
var sound : String = "res://audio/Weapon/gunshot.wav"

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
