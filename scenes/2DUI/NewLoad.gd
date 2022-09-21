extends Control

var highlighted = 0

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

func _input(event):
	if visible and event is InputEventKey and event.is_pressed() :
		$AudioStreamPlayer.play()
		match event.get_scancode_with_modifiers():
			KEY_ENTER:
				#print($VBoxContainer.get_child(highlighted).name)
				match highlighted:
					0:
						emit_signal("finished",[name,"new"])
					1:
						if !$VBoxContainer/Continue.disabled:
							emit_signal("finished",[name,"continue"])
				pass
			KEY_DOWN:
				if highlighted < $VBoxContainer.get_child_count()-1:
					highlighted += 1
				else:
					highlighted = 0
			KEY_UP:
				if highlighted > 0:
					highlighted -= 1
				else:
					highlighted = $VBoxContainer.get_child_count()-1
			#emit_signal("finished",[name])
