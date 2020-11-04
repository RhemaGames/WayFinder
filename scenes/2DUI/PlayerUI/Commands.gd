extends Control
var card = preload("res://scenes/CommandCard.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func load_commands(commands):

	for c in commands:
		if c["type"] == "general":
			var theCard = card.instance()
			$HBoxContainer.add_child(theCard)
			theCard.load_card(c)
			theCard.connect("execute",self,"on_command_execute")
			var _error = connect("ability_check",theCard,"_on_check_abilities")
			
	pass


func _on_Commands_gui_input(event):
	print(event)
	pass # Replace with function body.
