extends Control



signal finished(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_NewLoad_finished(_name):
	#queue_free()
	pass # Replace with function body.


func _on_New_pressed():
	$AudioStreamPlayer.play()
	emit_signal("finished",[name,"new"])
	pass # Replace with function body.


func _on_Continue_pressed():
	$AudioStreamPlayer.play()
	emit_signal("finished",[name,"continue"])
	pass # Replace with function body.
