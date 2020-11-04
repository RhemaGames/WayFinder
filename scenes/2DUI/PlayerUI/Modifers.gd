extends Control

# warning-ignore:unused_signal
signal finished(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func data_update(data):
	match data["type"]:
		"background":
			$Panel.modulate = Color(data["value"]) 
		"fontShadow":
			$HBoxContainer/count.set("custom_colors/font_color",Color(data["value"]))


func _on_Modifers_finished(_data):
	pass # Replace with function body.
