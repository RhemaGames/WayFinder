extends Spatial
var path = []
var available_connectors = []
var connectors = ["Connector1"]
var is_flipped = false
var rotated = 0
var flipped = 0
export var SPEED = 400
var points = []
# warning-ignore:unused_signal
signal flip 
# warning-ignore:unused_signal
signal place(location,parent)
signal placed()

var power = true
var inConflict = false

var type = "special"

var info = {
	"type":"special",
	"location":"engineering",
	"event":4,
	"cp":false,
	"encounter":false,
	"power":power,
	"main_event":true
}
var card_set = []

# Called when the node enters the scene tree for the first time.
func _ready():
	path = WayFinder.pathit(self)
	set_rotation_degrees(Vector3(rotation_degrees.x,rotation_degrees.y,0))
	
	
func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	var board = get_parent().get_parent()
	var thePlayer = WayFinder.players[WayFinder.turn -1]
	if event.is_pressed() and event.get_button_index() == 1 and thePlayer.turnSteps["build"] == true and thePlayer.turnSteps["move"] == false:
		var player = board.players[WayFinder.turn-1]
		var thepath = WayFinder.make_path(player,self)
		board.move_players(player,thepath)
		$Audio/confirm.play()
		
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "lightsOn":
		emit_signal("placed")
		check_event()

func _on_Engineering_place(_location, _parent):
	$AnimationPlayer.play("lightsOn")
	for a in $Area.get_overlapping_areas():
		print(a)
		inConflict = true

func on_add():
	$AnimationPlayer.play("lightsOn")
	
func check_event():
	if len(WayFinder.map) > 5:
		match info["event"]:
			4:
				if WayFinder.check_event_map(WayFinder.mainEvent):
					if WayFinder.check_event_location(info["location"],WayFinder.mainEvent):
						$Marker.add_child(get_parent().get_parent().marker.instance())


func update_points(player,doing):
	if doing == "landed":
		points.append(player)
		print ("Player on Card, Postion should now be, ",len(points)+1)
		
	if doing == "leaving":
		if points.find(player) != -1:
			points.remove(points.find(player))
			print ("Player leaving Card, Postion should now be, ",len(points)+1)

func card_aligned(overlap):
	var connector_list = []
	var is_aligned = false
	var card_type = ""
	#print(card_type.name)
	#print(overlap)
	match card_type:
		"card_line":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2]
		"card_T":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3]
		"card_cross":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3,$Connectors/Connector4]
		_:
			connector_list = [$Connectors/Connector1]
				
	if len(connector_list) > 0:
		for connector in connector_list:
			#print(connector.get_overlapping_areas())
			if str(connector) != "[Object:null]":
				if overlap in connector.get_overlapping_areas():
					#print(connector.name)
					is_aligned = true
					break
					
	return is_aligned


func _on_Engineering_placed():
	check_doors()
	pass # Replace with function body.

func check_doors():
	print("Checking doors")
	$Audio/confirm.play()
	
	var connector_list = [$Connectors/Connector1]
	for check in connector_list:
			var areas = check.get_overlapping_areas()
			for area in areas:
				if "card" in area.get_groups():
					match check.name:
						"Connector1":
								if area.get_parent().card_aligned(self.get_node("Area")) and $door/InnerDoor.visible:
									$door/InnerDoor.hide()
									$Audio/confirm.play()
									
						
func get_paths(ignore):
	var connector_list = []
	var pathlists = []
	connector_list = [$Connectors/Connector1]
	if power:
		for check in connector_list:
			var areas = check.get_overlapping_areas()
			for area in areas:
				if "card" in area.get_groups():
					match check.name:
						"Connector1":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if area.get_parent() != ignore:
									pathlists.append({"connector":1,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector2":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if area.get_parent() != ignore:
									pathlists.append({"connector":2,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector3":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if area.get_parent() != ignore:
									pathlists.append({"connector":3,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector4":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if area.get_parent() != ignore:
									pathlists.append({"connector":4,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
	return pathlists

func available_point():
	if len(points) == 0:
		return {"position":1,"location":$Marker.get_global_transform().origin}
	else:
		return {"position":len(points)+1,"location":$standardMovement.get_node("point"+str(len(points)+1)).get_global_transform().origin}

func check_connectors():
	var connectors = []
	for c in available_connectors:
		var overlap = self.get_node("Connectors/"+c).get_overlapping_areas()
		if overlap == []:
			connectors.append(c)

	return(connectors)
