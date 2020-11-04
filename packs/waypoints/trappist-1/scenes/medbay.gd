extends Spatial
var path = []
var is_flipped = true
var rotated = 0
var flipped = 0
export var SPEED = 400
# warning-ignore:unused_signal
signal flip 
signal place(location,parent)
signal placed(object)

var points = []
var inConflict = false

var power = true

var type = "special"

var info = {
	"type":"special",
	"location":"medical",
	"event":4,
	"cp":false,
	"encounter":false,
	"power":power,
	"main_event":true
}
var card_set = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var _error = ""
	path = WayFinder.pathit(self)
	set_rotation_degrees(Vector3(rotation_degrees.x,rotation_degrees.y,0))
	_error = $Connectors/Connector1.connect("mouse_entered",self,"card_input",[$Connectors/Connector1,"entered"])
	_error = $Connectors/Connector1.connect("mouse_exited",self,"card_input",[$Connectors/Connector1,"exited"])
	_error = $Connectors/Connector1.connect("input_event",self,"card_event",[$Connectors/Connector1])
	
	
func card_input(object,event):
	var covered = false 
	for overlap in object.get_overlapping_areas():
		if "card" in overlap.get_groups():
			covered = true
			break
		if "startpoint" in overlap.get_groups():
			covered = true
			break
	
	if is_flipped == true and WayFinder.players[WayFinder.turn -1].turnSteps["build"] == false and covered == false:
		
		if !object.name in card_set:
			if event == "entered":
				object.get_node("card_placement").show()
			else: 
				object.get_node("card_placement").hide()
		else:
			object.get_node("card_placement").hide()
	else:
		object.get_node("card_placement").hide()

func card_event(_camera, event, _click_position, _click_normal, _shape_idx,object):
	var covered = false 
	for overlap in object.get_overlapping_areas():
		if "card" in overlap.get_groups():
			covered = true
			break
		if "startpoint" in overlap.get_groups():
			covered = true
			break
	
	if event.is_pressed() and event.get_button_index() == 1 and covered == false and is_flipped == true:
		#var core_rot = object.get_parent().get_parent().rotation_degrees
		object.set_rotation_degrees(Vector3(object.rotation_degrees.x,object.rotation_degrees.y,0))
		if power:
			$Audio/confirm.play()
			emit_signal("place",object.global_transform,self)
		else:
			$Audio/error.play()
	
func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	var board = get_parent().get_parent()
	var thePlayer = WayFinder.players[WayFinder.turn -1]
	if event.is_pressed() and event.get_button_index() == 1 and thePlayer.turnSteps["build"] == true and thePlayer.turnSteps["move"] == false:
		print("Got Input")
		var player = WayFinder.players[WayFinder.turn-1]
		var thepath = WayFinder.make_path(player,self)
		board.move_players(player,thepath)
		$Audio/confirm.play()
		
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "lightsOn":
		emit_signal("placed")
		check_event()
		
func _on_medbay_place(_location, _parent):
	$AnimationPlayer.play("lightsOn")
	
	for a in $Area.get_overlapping_areas():
		if "card" in a.get_groups():
			print(a)
			inConflict = true

func on_add():
	$AnimationPlayer.play("lightsOn")
	for a in $Area.get_overlapping_areas():
		if "card" in a.get_groups():
			print(a)
			inConflict = true
	
func check_event():
	if len(WayFinder.map) > 5:
		match info["event"]:
			4:
				if WayFinder.check_event_map(WayFinder.mainEvent):
					if WayFinder.check_event_location(info["location"],WayFinder.mainEvent):
						$Marker.add_child(get_parent().get_parent().marker.instance())
						
func card_aligned(overlap):
	var connector_list = []
	var is_aligned = false
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
	
func get_paths(_ignore):
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
								pathlists.append({"connector":1,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector2":
							if area.get_parent().card_aligned(self.get_node("Area")):
								pathlists.append({"connector":2,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector3":
							if area.get_parent().card_aligned(self.get_node("Area")):
								pathlists.append({"connector":3,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector4":
							if area.get_parent().card_aligned(self.get_node("Area")):
								pathlists.append({"connector":4,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
	return pathlists

func available_point():
	if len(points) == 0:
		return {"position":1,"location":$Marker.get_global_transform().origin}
	else:
		return {"position":len(points)+1,"location":$standardMovement.get_node("point"+str(len(points)+1)).get_global_transform().origin}

func on_point(player):
	var point_found = {"player":player,"location":null}
	if len(points) > 0:
		for p in points:
			if p["player"] == player:
				point_found = p
				break
	return point_found
			
func update_points(player,doing):
	#print(doing)
	if doing == "landed":
		points.append({"player":player,"location":available_point()["location"]})
		#print ("Player on Card, Postion should now be, ",len(points)+1)
		
	if doing == "leaving":
		for p in points:
			if p["player"] == player:
				points.remove(points.find(p))
				break
		#print ("Player leaving Card, Postion should now be, ",len(points)+1)
