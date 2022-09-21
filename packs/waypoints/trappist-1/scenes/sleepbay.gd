extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# warning-ignore:unused_signal
signal character_Select
# warning-ignore:unused_signal
signal character_next
# warning-ignore:unused_signal
signal character_back

# warning-ignore:unused_signal
signal placed()
signal place(location,parent)

var cardSet1 = false
var cardSet2 = false
var power = true
var Combatant
var path = []
var is_flipped = true
var rotated = 0
var flipped = 0
export var SPEED = 400

var inConflict = false

var points = []

var info = {
	"type":"special",
	"location":"sleepbay",
	"event":0,
	"cp":false,
	"encounter":false,
	"power":power,
	"main_event":false
}
var card_set = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var _error = ""
	for c in ["Connector1","Connector2","Connector3","Connector4"]:
		_error = $Connectors.get_node(c).connect("mouse_entered",self,"card_input",[$Connectors.get_node(c),"entered"])
		_error = $Connectors.get_node(c).connect("mouse_exited",self,"card_input",[$Connectors.get_node(c),"exited"])
		_error = $Connectors.get_node(c).connect("input_event",self,"card_event",[$Connectors.get_node(c)])


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
			

func _on_Start_character_Select():
	$characterSelectPoint/CharacterSelect.show()

func _on_Start_character_back():
	$characterSelectPoint/CharacterSelect.change_class(-1)


func _on_Start_character_next():
	$characterSelectPoint/CharacterSelect.change_class(1)

func _on_Start_placed():
	$Audio/AudioStreamPlayer.play()
	#$HyperSleepChamber/door/InnerDoor.hide()
	check_doors()
	#$HyperSleepChamber/door001/InnerDoor001.hide()

func check_doors():
	print("Checking doors")
	$Audio/AudioStreamPlayer.play()
	
	var connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3,$Connectors/Connector4]
	for check in connector_list:
			var areas = check.get_overlapping_areas()
			for area in areas:
				if "card" in area.get_groups():
					match check.name:
						"Connector1":
								if area.get_parent().card_aligned(self.get_node("Area")) and $Sleepchambers/door/InnerDoor.visible:
									$Sleepchambers/door/InnerDoor.hide()
									$Audio/AudioStreamPlayer.play()
						"Connector2":
								if area.get_parent().card_aligned(self.get_node("Area")) and $Sleepchambers/door4/InnerDoor002.visible:
									$Sleepchambers/door4/InnerDoor002.hide()
									$Audio/AudioStreamPlayer.play()
						"Connector3":
								if area.get_parent().card_aligned(self.get_node("Area")) and $Sleepchambers/door3/InnerDoor003.visible:
									$Sleepchambers/door3/InnerDoor003.hide()
									$Audio/AudioStreamPlayer.play()
						"Connector4":
								if area.get_parent().card_aligned(self.get_node("Area")) and $Sleepchambers/door2/InnerDoor001.visible:
									$Sleepchambers/door2/InnerDoor001.hide()
									$Audio/AudioStreamPlayer.play()
	#if power:		
	#	for check in connector_list:
	#		var areas = check.get_overlapping_areas()
	#		for area in areas:
	#			if "card" in area.get_groups():
	#				
	#				if str(var1) == str(area.get_parent()):
	#					match check.name:
	#						"Connector1":
	#							if card_type.get_door(0) == "closed":
	#								card_type.door(0,"open")
	#								$Audio/AudioStreamPlayer.play()
	#						"Connector3":
	#							if card_type.get_door(1) == "closed":
	#								card_type.door(1,"open")
	#								$Audio/AudioStreamPlayer.play()
	#						"Connector4":
	#							if card_type.get_door(2) == "closed":
	#								card_type.door(2,"open")
	#								$Audio/AudioStreamPlayer.play()

func on_add():
	#$AnimationPlayer.play("lightsOn")
	pass

func on_point(player):
	var point_found = {"player":0,"location":null}
	if len(points) > 0:
		for p in points:
			if p["player"] == player:
				point_found = p
				break
	return point_found

func update_points(player,doing):
	if doing == "landed":
		points.append({"player":player,"location":available_point()["location"]})
		#print ("Player on Card, Postion should now be, ",len(points)+1)
		
	if doing == "leaving":
		for p in points:
			if p["player"] == player:
				points.remove(points.find(p))
				break
		#print ("Player leaving Card, Postion should now be, ",len(points)+1)


func _on_sleepbay_place(_location, _parent):
	for a in $Area.get_overlapping_areas():
		if "card" in a.get_groups():
			print(a)
			inConflict = true
	pass # Replace with function body.

func _on_card_placed(_object):
	check_doors()
	pass # Replace with function body.

func card_aligned(overlap):
	var connector_list = []
	var is_aligned = false
	connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3,$Connectors/Connector4]
	if len(connector_list) > 0:
		for connector in connector_list:
			#print(connector.get_overlapping_areas())
			if str(connector) != "[Object:null]":
				if overlap in connector.get_overlapping_areas():
					#print(connector.name)
					is_aligned = true
					break
					
	return is_aligned


func _on_Area_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	
	var board = get_parent().get_parent()
	if event.is_pressed() and event.get_button_index() == 1 and WayFinder.players[WayFinder.turn -1].turnSteps["build"] == true and WayFinder.players[WayFinder.turn -1].turnSteps["move"] == false:
		var player = board.players[WayFinder.turn-1]
		var thepath = WayFinder.make_path(player,self)
		board.move_players(player,thepath)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func get_paths(ignore):
	var connector_list = []
	var pathlists = []
	connector_list = [$Connectors/Connector1,$Connectors/Connector2,$Connectors/Connector3,$Connectors/Connector4]
	if power:
		for check in connector_list:
			var areas = check.get_overlapping_areas()
			for area in areas:
				if "card" in area.get_groups():
					match check.name:
						"Connector1":
							if area.get_parent().card_aligned(self.get_node("Area")):
								#if area.get_parent() != ignore:
									pathlists.append({"connector":1,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector2":
							if area.get_parent().card_aligned(self.get_node("Area")):
								#if area.get_parent() != ignore:
									pathlists.append({"connector":2,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector3":
							if area.get_parent().card_aligned(self.get_node("Area")):
								#if area.get_parent() != ignore:
									pathlists.append({"connector":3,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
						"Connector4":
							if area.get_parent().card_aligned(self.get_node("Area")):
								#if area.get_parent() != ignore:
									pathlists.append({"connector":4,"card":area.get_parent(),"parent":self})
							#else:
							#	pathlists.append({"connector":1,"card":null,"parent":self})
	return pathlists

func available_point():
	if $p1.visible:
		if len(points) == 0:
			return {"position":1,"location":$p1.translation}
		else:
			return {"position":len(points)+1,"location":$standardMovement.get_node("point"+str(len(points)+1)).translation}
