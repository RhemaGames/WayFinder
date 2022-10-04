extends Spatial

var availableClasses = []
var players = []
var playersReady = []
var held = 0
var holding = false
var selecting = false
var classShown = 0
onready var fullname = WayFinder.generate_name()
#signal finished(data)

signal change(num,crewType)


# Called when the node enters the scene tree for the first time.
func _ready():
	var _error = null
	var start = load("res://packs/waypoints/trappist-1/encounters/ArrivalStart.tscn").instance()
	$Location.add_child(start)
	$Camera/CharacterSelect/AnimationPlayer.play("powerup")
	_error = connect("change",$Camera/CharacterSelect/Viewport.get_child(0),"_on_PlayerSelectArea_change")
	_error = connect("change",$Camera/Health/Viewport.get_child(0),"set_hp")
	_error = $Camera/Name/Viewport.get_child(0).connect("entering_text",self,"set_name")
	
	pass # Replace with function body.


func set_name(text):
	if len(text.split(" ")) > 1:
		fullname = {"name":text.split(" ")[0],"surname":text.split(" ")[1]}
	else:
		fullname = {"name":text.split(" ")[0],"surname":""}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#$CharacterSelect.rotate_y(0.01)
	pass

func _unhandled_key_input(event):
	if visible and event.is_pressed():
		
		match event.get_scancode_with_modifiers():
			KEY_SPACE:
				if !$Camera/Name/Viewport.get_child(0).get_node("NameArea/Name").has_focus() and len(players) < 4:
					if len(playersReady) == len(players):
						fullname = WayFinder.generate_name()
						$Camera/Name/Viewport.get_child(0).get_node("NameArea/Name").text = fullname["name"]+" "+fullname["surname"]
						$Camera/CharacterSelect/Viewport.get_child(0).select()
						players.append({"input":"keyboard"})
						selecting = true
						var player_location = $Location.get_child(0).get_node("Players/Player"+str(len(players)))
						#$Camera.global_transform = player_location.get_node("Camera").global_transform
						#$Camera.rotation = player_location.get_node("Camera").rotation
						#$Camera.look_at(player_location.transform.origin,Vector3(0,1,0))
						if player_location.get_child_count() > 1:
							player_location.get_child(1).queue_free()
						emit_signal("change",len(players),availableClasses[classShown])
						player_location.add_child(availableClasses[classShown]["data"].instance())
					else:
						print("player ",len(players)," Not locked in")
			KEY_LEFT:
				if selecting == true:
					var player_location = $Location.get_child(0).get_node("Players/Player"+str(len(players)))
					if classShown > 0:
						classShown -= 1
						emit_signal("change",len(players),availableClasses[classShown])
					else:
						classShown = len(availableClasses)-1
						emit_signal("change",len(players),availableClasses[classShown])
					if player_location.get_child_count() > 1:
						player_location.get_child(1).queue_free()
					player_location.add_child(availableClasses[classShown]["data"].instance())
			KEY_RIGHT:
				if selecting == true:
					var player_location = $Location.get_child(0).get_node("Players/Player"+str(len(players)))
					if classShown < len(availableClasses)-1:
						classShown += 1
						emit_signal("change",len(players),availableClasses[classShown])
					else:
						classShown = 0
						emit_signal("change",len(players),availableClasses[classShown])
					if player_location.get_child_count() > 1:
						player_location.get_child(1).queue_free()
					player_location.add_child(availableClasses[classShown]["data"].instance())
					
			KEY_ENTER:
				if !$Camera/Name/Viewport.get_child(0).get_node("NameArea/Name").has_focus() and len(players) <= 4 and len(players) > len(playersReady):
					$Camera/CharacterSelect/AnimationPlayer.play_backwards("powerup")
					#$WFpanel/fullbox/Control.get_child(len(playersReady)).lock_in()
					playersReady.append({"player":len(players)})
					player_add("nobody",availableClasses[classShown])
					selecting = false
					classShown = 0
					player_check()
				else:
					if !holding:
						$holdcount.start()
						holding = true
						
			KEY_TAB:
				if !$Camera/Name/Viewport.get_child(0).get_node("NameArea/Name").has_focus():
					$Camera/Name/Viewport.get_child(0).get_node("NameArea/Name").grab_focus()
				else:
					$Camera/Name/Viewport.get_child(0).get_node("NameArea/Name").release_focus()
					
	elif visible:
		$holdcount.stop()
		holding = false
		held = 0
			
func player_add(_characterName,CharacterData):
	
	var classInfo = CharacterData["data"].instance().get_info() 
	var characterMap = WayFinder.player.instance()
	characterMap.playernum = len(WayFinder.players)
	characterMap.info["class"] = CharacterData["class"]
	characterMap.info["name"] = fullname["name"]+" "+fullname["surname"]
	characterMap.info["maxHp"] = classInfo["hp"]
	characterMap.info["hp"] = classInfo["hp"]
	characterMap.info["cp"] = 1
	characterMap.info["canMove"] = true
	characterMap.info["canAttack"] = true
	characterMap.info["level"] = 1
	characterMap.info["unlocks"] = []
	WayFinder.players.append(characterMap)
	remove_class(classInfo["class"])

func remove_class(used):
	for theclass in availableClasses:
		var classInfo = theclass["data"].instance().get_info()
		if classInfo["class"] == used:
			availableClasses.remove(availableClasses.find(theclass))
			break
			

func player_check():
	if len(players) >= 2 and len(players) < 4:
		var player_location = $Location.get_child(0).get_node("Players/Player"+str(len(players)+1))
		$Camera.global_transform = player_location.get_node("Camera").global_transform
		$Camera.rotation = player_location.get_node("Camera").rotation
		$Camera/CharacterSelect/Viewport.get_child(0).lock_in()
		$Camera/CharacterSelect/AnimationPlayer.play("powerup")
		pass
	elif len(players) < 2:
		
		var player_location = $Location.get_child(0).get_node("Players/Player"+str(len(players)+1))
		$Camera.global_transform = player_location.get_node("Camera").global_transform
		$Camera.rotation = player_location.get_node("Camera").rotation
		
		$Camera/CharacterSelect/Viewport.get_child(0).lock_in()
		$Camera/CharacterSelect/AnimationPlayer.play("powerup")
		#$WFpanel/fullbox/hint.text ="2 or more players needed to begin the game"
		pass
	else:
		WayFinder.gamesettings["players"] = len(players)
		WayFinder.emit_signal("startGame",WayFinder.gamesettings)

func _on_Pselect_visibility_changed():
	if visible:
		$Camera.make_current()
		for classes in WayFinder.classes:
			availableClasses.append(classes)
		player_check()



func _on_holdcount_timeout():
	if held == 3:
		WayFinder.gamesettings["players"] = len(players)
		WayFinder.emit_signal("startGame",WayFinder.gamesettings)
	else:
		held += 1
		#$WFpanel/fullbox/hint.text ="Holding Enter ("+str(4-held)+")"
