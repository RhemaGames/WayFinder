extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if $power_outage.visible:
		$power_outage.hide()
	else:
		$power_outage.show()
		
	pass # Replace with function body.


func _on_event3_visibility_changed():
	if visible:
		$Timer.start()
	else:
		$Timer.stop()
		
	pass # Replace with function body.
