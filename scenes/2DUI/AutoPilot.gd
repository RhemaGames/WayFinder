extends Control


# warning-ignore:unused_signal
signal finished(data)

var message = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if message == 1:
		$Label.text = "Auto Pilot Engaged"
		message = 0
	else:
		$Label.text = "Manual Controls Disabled"
		message = 1
	
	pass # Replace with function body.


func _on_AutoPilot_finished(_data):
	pass # Replace with function body.
