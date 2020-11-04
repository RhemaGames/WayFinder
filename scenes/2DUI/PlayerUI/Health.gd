extends Control

# warning-ignore:unused_signal
signal finished(data)

export var test_color = Color(0.278431, 0.784314, 0.988235,0.5)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func data_update(data):
	match data["type"]:
		"background":
			$WFpanel.self_modulate = Color(data["value"])
		"fontShadow":
			$HBoxContainer/count.set("custom_colors/font_color",Color(data["value"]))
		


func _on_Health_finished(_data):
	pass # Replace with function body.
