extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal showInfo(text)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.emit_signal("showInfo","How you doing")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_InfoBox_showInfo(text):
	$Texts.bbcode_text = text
	pass # Replace with function body.
