extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var data

signal finished(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	#$WFpanel/MarginContainer/RichTextLabel/AnimationPlayer.play("appear")
	for point in WayFinder.waypoints:
		var cwaypoint = WayFinder.gamesettings["waypoint"]
		if point["folder"] == cwaypoint:
			list_Missions(point)
			break
	#list_Missions(data)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Mission_finished(_name):
	#queue_free()
	pass # Replace with function body.


func _on_Mission_pressed(waypoint):
	$Pressed.play()
	emit_signal("finished",[name,waypoint])

func _on_Mission_entered(about):
	if about.has("file"):
		$Entered.play()
		var missionFile = load(about["file"]).instance()
		$WFpanel/MarginContainer/RichTextLabel.bbcode_text = missionFile.info
		$WFpanel/MarginContainer/RichTextLabel/AnimationPlayer.play("appear")
	

func _on_BackButton_pressed():
	$Pressed.play()
	emit_signal("finished",[name,"back"])
	
func list_Missions(_data):
	if typeof(_data) == TYPE_DICTIONARY:
		for m in _data["missions"]:
			var _found = false
			var button = Button.new()
			button.text = m["title"]
			button.connect("pressed",self,"_on_Mission_pressed",[m])
			button.connect("mouse_entered",self,"_on_Mission_entered",[m])
			for unlocked in WayFinder.gamedata["unlocked"]:
				
				if _data["title"] == unlocked["waypoint"]:
					if m["title"] == unlocked["mission"]:
						_found = true
						break

			$MissionSelect/MarginContainer/VBoxContainer/MissionList.add_child(button)
