extends Control

signal finished(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if $Label.visible:
		$Label.hide()
	else:
		$Label.show()
		
	pass # Replace with function body.


func _on_Start_gui_input(event):
	if visible and event.is_pressed():
		$AudioStreamPlayer.play()
		emit_signal("finished",[name])


func _on_Start_finished(_name):
	$Timer.stop()
	$Label.hide()
	$WFpanel.hide()
	pass # Replace with function body.

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
			$AudioStreamPlayer.play()
			emit_signal("finished",[name])
