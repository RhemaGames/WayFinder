extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_info(data):
	$HBoxContainer/VBoxContainer/title.text = data[0]
	$HBoxContainer/VBoxContainer/RichTextLabel.text = data[1]
	$HBoxContainer/TextureRect.texture = data[2]


func _on_Highlight_visibility_changed():
	if $Highlight.visible:
		$Timer.start()
	pass # Replace with function body.


func _on_Timer_timeout():
	$Highlight.hide()
	pass # Replace with function body.


func _on_Command_resized():
	pass # Replace with function body.
