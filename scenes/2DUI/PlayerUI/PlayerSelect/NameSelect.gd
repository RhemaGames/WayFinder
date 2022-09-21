extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal entering_text(text)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Name_text_changed(new_text):
	emit_signal("entering_text",new_text)
	pass # Replace with function body.
