extends Panel

@onready var background_sprite : Sprite2D = $Background
@onready var ability_sprite : Sprite2D = $Ability
@onready var ability_name : Label = $Name
@onready var ability_description : RichTextLabel = $Description
@onready var quantity : Label = $Quantity

var current_ability : Ability

func update(ability : Ability):
	current_ability = ability
	
	if ability:
		background_sprite.visible = true
		ability_sprite.visible = true
		ability_name.visible = false
		ability_description.visible = false
		ability_sprite.texture = ability.texture
		quantity.visible = false
		if ability.quantity > 1:
			quantity.visible = true
			quantity.text = str(ability.quantity)
		
	else:
		background_sprite.visible = true
		ability_sprite.visible = true
		ability_name.visible = true
		ability_description.visible = true
		ability_sprite.texture = ability.texture
		ability_name.text = ability.ability_name
		ability_description.text = ability.description
		if ability.quantity > 1:
			quantity.visible = true
			quantity.text = str(ability.quantity)
