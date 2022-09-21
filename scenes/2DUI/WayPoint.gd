extends Control

var highlighted = 0

signal finished(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	#$WFpanel/MarginContainer/RichTextLabel/AnimationPlayer.play("appear")
	list_wayPoints()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_WayPoint_finished(_name):
	$Pressed.play()
	#queue_free()
	pass # Replace with function body.


func _on_WayPoint_pressed(waypoint):
	$Pressed.play()
	emit_signal("finished",[name,waypoint])
	pass # Replace with function body.

func _on_WayPoint_entered(m):
	$Entered.play()
	$WFpanel/MarginContainer/RichTextLabel.bbcode_text = m["about"]
	$WFpanel/MarginContainer/RichTextLabel/AnimationPlayer.play("appear")
	get_node("../../../../LeftScreen/GUIPanel3D").load_ui(m["screens"][0]["file"])
	get_node("../../../../RightScreen/GUIPanel3D").load_ui(m["screens"][1]["file"])

func _on_BackButton_pressed():
	$Pressed.play()
	emit_signal("finished",[name,"back"])
	pass # Replace with function body.
	
func list_wayPoints():
	for m in WayFinder.waypoints:
		var button = Button.new()
		button.text = m["title"]
		button.connect("pressed",self,"_on_WayPoint_pressed",[m])
		button.connect("mouse_entered",self,"_on_WayPoint_entered",[m])
		button.connect("focus_entered",self,"_on_WayPoint_entered",[m])
		$SystemSelect/MarginContainer/VBoxContainer/SystemList.add_child(button)
	

func _on_WayPoint_visibility_changed():
	if visible:
		$SystemSelect/MarginContainer/VBoxContainer/SystemList.get_child(0).grab_focus()
	pass # Replace with function body.
