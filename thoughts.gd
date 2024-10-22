extends Area2D
var dialogue = [""]
var id = 0
var done = false

@onready var DialogContainer = get_parent().get_node("Player").get_node("dialogue Container")
@onready var player = get_parent().get_node("Player")
func _ready():
	DialogContainer.hide()
	id = int(self.name.split(" ")[0])



func _process(_delta):
	DialogContainer.dialogFinished.disconnect(setDone)
	DialogContainer.visible=false
	get_tree().paused = false
	queue_free()
	if id == 0: #this is a place holder
		DialogContainer.show()
		DialogContainer.reset(dialogue[id])
		get_tree().paused = true
		DialogContainer.dialogFinished.connect(setDone)


func setDone():
	done=true
