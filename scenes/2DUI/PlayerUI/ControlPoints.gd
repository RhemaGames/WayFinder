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
		"count": 
			var data_string = "00"
			if data["value"] < 10:
				data_string = "0"+str(data["value"])
			else:
				data_string = str(data["value"])
			$WFpanel/Panel/HBoxContainer/count.text = str(data_string)
		"background":
			$WFpanel.self_modulate = Color(data["value"])
		"fontShadow":
			$WFpanel/Panel/HBoxContainer/count.set("custom_colors/font_color",Color(data["value"]))
			$WFpanel.border_color = Color(data["value"])


func _on_ControlPoints_finished(_data):
	pass # Replace with function body.
