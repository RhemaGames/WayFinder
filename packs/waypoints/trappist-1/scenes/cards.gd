extends Spatial

var objectPoints = []
var panelPoints = []
var doors = []

signal door(status)

func _ready():
	gather_object_points()
	match name:
		"card_line":
			door(0,"close")
			door(1,"close")
		"card_T":
			door(0,"close")
			door(1,"close")
			door(2,"close")
		"card_cross":
			door(0,"close")
			door(1,"close")
			door(2,"close")
			door(3,"close")

func gather_object_points():
	for child in get_children():
		if str(child.name).similarity("Object") > 0.9:
			objectPoints.append(child)
		if str(child.name).similarity("Panel") > 0.88:
			panelPoints.append(child)
		if str(child.name).similarity("door") > 0.8:
			doors.append(child)

func get_panels():
	for child in get_children():
		if str(child.name).similarity("Panel") > 0.88:
			panelPoints.append(child)
	return panelPoints
	
func get_objects():
	for child in get_children():
		if str(child.name).similarity("Object") > 0.9:
			objectPoints.append(child)
	return objectPoints

func get_door(doorId):
	for door in doors:
		if "door"+str(doorId) == door.name:
			#print("Getting door ",door.name)
			if door.get_child(0).translation.y <= 1:
				return "closed"
			else:
				return "opened"
		
func door(doorId,state):
	for door in doors:
		if "door"+str(doorId) == door.name:
			match state:
				"close":
					door.get_child(0).translate_object_local(Vector3(0,0,0))
					emit_signal("door","closed")
					door.get_child(0).show()
				"open":
					door.get_child(0).translate_object_local(Vector3(0,3,0))
					emit_signal("door","opened")
					door.get_child(0).hide()
