extends Spatial

var Combatant
var path = []
var connectors = []
var available_connectors = []
var is_flipped = true
var rotated = 0
var flipped = 0
export var SPEED = 400
# warning-ignore:unused_signal
#signal flip 
signal place(location,parent)
signal placed()

var power = true

var points = []

var type = "T"
var info = {
	"type":"T",
	"event":0,
	"cp":false,
	"encounter":false,
	"location":"card",
	"power":power
}
var card_set = []
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play_backwards("PopUp")
	$Model/AnimationPlayer.play("lift")
	var _error = WayFinder.connect("movementType",self,"on_movementType_change")
	#_error = WayFinder.currentView.connect("mapUpdate",self,"check_connectors")
	match type:
		"line":
			var line = WayFinder.currentMission.cards[0].instance()
			add_objects(line.get_objects())
			add_panels(line.get_panels())
			available_connectors = ["Connector1","Connector2"]
			$Model.add_child(line)
				
		"T":
			var t = WayFinder.currentMission.cards[1].instance()
			add_objects(t.get_objects())
			add_panels(t.get_panels())
			available_connectors = ["Connector1","Connector2","Connector3"]
			$Model.add_child(t)
				
		"cross":
			var cross = WayFinder.currentMission.cards[2].instance()
			add_objects(cross.get_objects())
			add_panels(cross.get_panels())
			available_connectors = ["Connector1","Connector2","Connector3","Connector4"]
			$Model.add_child(cross)
		
	for c in available_connectors:
		_error = $Connectors.get_node(c).connect("mouse_entered",self,"card_input",[$Connectors.get_node(c),"entered"])
		_error = $Connectors.get_node(c).connect("mouse_exited",self,"card_input",[$Connectors.get_node(c),"exited"])
		_error = $Connectors.get_node(c).connect("input_event",self,"card_event",[$Connectors.get_node(c)])
	connectors = available_connectors
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	pass
	#var new_rotation = 0
	#var new_flipped = 0
	#var rot_vec = Vector3(0,0,0)
	#if is_flipped:
	#	new_flipped = 180
	#	if int($Model.rotation_degrees.y) < rotated:
	#		new_rotation = $Model.rotation_degrees.y + (0.01 * SPEED)
	#		rot_vec = Vector3(0,new_rotation,new_flipped)
			#	$Connectors.set_rotation_degrees(rot_vec)
	#		$Model.set_rotation_degrees(rot_vec)
	#		$Area.set_rotation_degrees(rot_vec)
	#	elif int($Model.rotation_degrees.y) > rotated:
	#		new_rotation = rotated
	#		rot_vec = Vector3(0,new_rotation,new_flipped)
	#		$Model.set_rotation_degrees(rot_vec)
			#$Connectors.set_rotation_degrees(rot_vec)
	#else:
	#	if int($Model.rotation_degrees.z) < flipped:
			
	#		new_flipped = $Model.rotation_degrees.z + (0.01 * SPEED)
	#		$Model.set_rotation_degrees(Vector3(0,new_rotation,new_flipped))
	#		#$Connectors.set_rotation_degrees(rot_vec)
	#	else:
	#		new_flipped = flipped
	#		is_flipped = true
	#		if !$AnimationPlayer.is_playing():
	#			$AnimationPlayer.play("PopUp")
	#			check_event()
	
func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	
	var board = get_parent().get_parent()
	if event.is_pressed() and event.get_button_index() == 1 and WayFinder.players[WayFinder.turn -1].turnSteps["build"] == true and WayFinder.players[WayFinder.turn -1].turnSteps["move"] == false:
		var player = board.players[WayFinder.turn-1]
		var thepath = WayFinder.make_path(player,self)
		board.move_players(player,thepath)
		
#func _on_card_flip():
#	flipped = 180
	
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
			
			
func _on_Timer_timeout():
	check_event()

func check_event():
	match info["event"]:
		
		0: 
			$Lights/OmniLight.show()
			$Lights/OmniLight2.show()
			$event3.hide()
			power = true
		3:
			if len(WayFinder.map) > 5 and WayFinder.currentView.unlocks.has("event3"):
				$Lights/OmniLight.hide()
				$Lights/OmniLight2.hide()
				$event3.show()
				power = false
		4:
			if WayFinder.check_event_map(WayFinder.mainEvent):
				if WayFinder.check_event_location(info["location"],WayFinder.mainEvent):
					$Marker.add_child(get_parent().get_parent().marker.instance())
					#WayFinder.mainEventFound = true
					
		#2:
		#	if WayFinder.check_event_map(WayFinder.mainEvent):
		#		if WayFinder.check_event_location(info["location"],WayFinder.mainEvent):
		#			$Marker.add_child(get_parent().marker.instance())
					#WayFinder.mainEventFound = true
				

func add_panels(_points):
	for spot in _points:
		randomize()
		var panelnum = round(rand_range(0,5))
		if panelnum < len(WayFinder.currentMission.panels):
			spot.add_child(WayFinder.currentMission.panels[panelnum].instance())

# warning-ignore:shadowed_variable
func add_objects(points):
	for spot in points:
		randomize()
		var objectnum = round(rand_range(0,5))
		if objectnum < len(WayFinder.currentMission.objects):
			var obj = WayFinder.currentMission.objects[objectnum].instance()
			spot.add_child(obj)

func find_card():
	for child in $Model.get_children():
		if child.name in ["card_line","card_T","card_cross","special"]:
			return child


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "lift":
		emit_signal("placed") 
		#check_doors()

func check_doors():
	var card_type = find_card()
	var connector_list = []
	match card_type.name:
		"card_line":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2]
		"card_T":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3]
		"card_cross":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3,$Connectors/Connector4]
		_:
			connector_list = [$Connectors/Connector1]
	if power:
		available_connectors = []		
		for check in connector_list:
			var areas = check.get_overlapping_areas()
			for area in areas:
				if "card" in area.get_groups():
					#print(area.get_parent().card_aligned(self.get_node("Area")))
					match check.name:
						"Connector1":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if card_type.get_door(1) == "closed":
									card_type.door(1,"open")
									$Audio/AudioStreamPlayer.play()
									connectors.erase("Connector1")
									
						"Connector2":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if card_type.get_door(0) == "closed":
									card_type.door(0,"open")
									$Audio/AudioStreamPlayer.play()
									connectors.erase("Connector2")
									
						"Connector3":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if card_type.get_door(2) == "closed":
									card_type.door(2,"open")
									$Audio/AudioStreamPlayer.play()
									connectors.erase("Connector3")
																
						"Connector4":
							if area.get_parent().card_aligned(self.get_node("Area")):
								if card_type.get_door(3) == "closed":
									card_type.door(3,"open")
									$Audio/AudioStreamPlayer.play()
									connectors.erase("Connector4")
									
	WayFinder.currentView.emit_signal("mapUpdate")
										
func on_event_changed():
	#print(info["event"])
	if info["event"] == 4:
		if WayFinder.check_event_map(WayFinder.mainEvent):
				if WayFinder.check_event_location(info["location"],WayFinder.mainEvent):
					$Marker.show()
				else:
					$Marker.hide()

func command(action):
	match action:
		"fixed":
			match info["event"]:
				3:
					info["event"] = 0
					check_event()
					return 1

func on_movementType_change(changeTo):
	$standardMovement.hide()
	$cautionMovement.hide()
	$combatMovement.hide()
		
	match changeTo:
		"Standard":
			$standardMovement.show()
		"Caution":
			$cautionMovement.show()
		"Combat":
			$combatMovement.show()

func available_point():
	if $standardMovement.visible:
		if len(points) == 0:
			return {"position":1,"location":$standardMovement/point1.get_global_transform().origin}
		else:
			#print("Move to point ",len(points))
			return {"position":len(points),"location":$standardMovement.get_node("point"+str(len(points))).get_global_transform().origin}
			
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


func _on_card_placed():
	check_doors()
	#WayFinder.currentView.emit_signal("mapUpdate")
	#check_connectors()
	#available_connectors = check_connectors()
	pass # Replace with function body.

func card_aligned(overlap):
	var connector_list = []
	var is_aligned = false
	var card_type = find_card()
	match card_type.name:
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
			#if str(connector) != "[Object:null]":
			if overlap in connector.get_overlapping_areas():
				#connectors.pop_at(connectors.find(connector.name))
				is_aligned = true
				break
					
	return is_aligned

# warning-ignore:unused_argument
func get_paths(ignore):
	var card_type = find_card()
	var connector_list = []
	var pathlists = []
	
	match card_type.name:
		"card_line":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2]
		"card_T":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3]
		"card_cross":
			connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3,$Connectors/Connector4]
		_:
			connector_list = [$Connectors/Connector1]
			
	if power:
		for check in connector_list:
			var areas = check.get_overlapping_areas()
			for area in areas:
				if "card" in area.get_groups():
					match check.name:
						"Connector1":

							if area.get_parent().card_aligned(self.get_node("Area")) and card_type.get_door(1) == "opened":
								pathlists.append({"connector":1,"card":area.get_parent(),"parent":self})
															
						"Connector2":

							if area.get_parent().card_aligned(self.get_node("Area")):
								pathlists.append({"connector":2,"card":area.get_parent(),"parent":self})
									
						"Connector3":

							if area.get_parent().card_aligned(self.get_node("Area")) and card_type.get_door(2) == "opened":
								pathlists.append({"connector":3,"card":area.get_parent(),"parent":self})
								
						"Connector4":

							if area.get_parent().card_aligned(self.get_node("Area")) and card_type.get_door(3) == "opened":
								pathlists.append({"connector":4,"card":area.get_parent(),"parent":self})
	check_doors()
	
	return pathlists


func _on_Area_body_shape_entered(_body_id, body, _body_shape, _area_shape):
	#print("Entered, ",body)
	update_points(body,"landed")
	pass # Replace with function body.


func _on_Area_body_shape_exited(_body_id, body, _body_shape, _area_shape):
	#print("Exited, ",body)
	update_points(body,"leaving")
	pass # Replace with function body.

#func check_connectors():
	
#	for c in available_connectors:
#		var overlap = self.get_node("Connectors/"+c).get_overlapping_areas()
#		if overlap == []:
#			if !c in connectors:
#				connectors.append(c)
#		else:
#			if c in connectors:
#				connectors.pop_at(connectors.find(c))
			#if "card" in overlap.get_groups():
			#	covered = true
			#if "startpoint" in overlap.get_groups():
			#	covered = true
#	return(connectors)
