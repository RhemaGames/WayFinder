extends Control


# warning-ignore:unused_signal
signal finished(data)

var pods = 20
var status =1
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Timer_timeout():
	if pods > 1:
		$WFpanel/MarginContainer/GridContainer.add_child($WFpanel/MarginContainer/GridContainer.get_child(0).duplicate(1))
		pods -=1
		$WFpanel2/MarginContainer/ScrollContainer/VBoxContainer.add_child($WFpanel2/MarginContainer/ScrollContainer/VBoxContainer/Line.duplicate(1))
	
	pass # Replace with function body.


func _on_Stasis_finished(_data):
	pass # Replace with function body.
