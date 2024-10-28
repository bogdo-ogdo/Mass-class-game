extends Panel

@export var commonColor : Color
@export var rareColor : Color
@export var legendaryColor : Color

@export var sparkle : Node2D

@onready var ability_sprite : TextureRect = $Icon
@onready var ability_name : Label = $Name
@onready var ability_description : RichTextLabel = $Description
@onready var quantity : Label = $Quantity
@onready var shine : TextureRect = $shine

var current_ability : Ability

func update(ability : Ability):
	current_ability = ability
	sparkle.visible = false
	shine.visible = false
	$Fire.visible = false
	if ability:
		ability_sprite.visible = true
		ability_name.visible = false
		ability_description.visible = false
		ability_sprite.texture = ability.texture
		ability_name.text = ability.ability_name
		quantity.visible = false
		
		if ability.rarity == 0:
			set_color(commonColor)
		if ability.rarity == 1:
			set_color(rareColor)
		if ability.rarity == 2:
			set_color(legendaryColor)
			sparkle.visible = true
			shine.visible = true
			$Fire.visible = true
		
		if ability.quantity > 1:
			quantity.visible = true
			quantity.text = str(ability.quantity)
		
	else:
		ability_sprite.visible = true
		ability_name.visible = true
		ability_description.visible = true
		ability_sprite.texture = ability.texture
		ability_name.text = ability.ability_name
		ability_description.text = ability.description
		if ability.quantity > 1:
			quantity.visible = true
			quantity.text = str(ability.quantity)


func _on_mouse_entered():
	ability_name.visible = true

func _on_mouse_exited():
	ability_name.visible = false

func set_color(color : Color):
	self_modulate = color
