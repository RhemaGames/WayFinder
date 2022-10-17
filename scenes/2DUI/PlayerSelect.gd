extends Control

var Select = preload("res://scenes/2DUI/PlayerUI/PlayerSelect/PlayerSelectArea.tscn")

var players = []
var playersReady = []
var held = 0
var holding = false
var selecting = false
var classShown = 0

var availableClasses = []
signal finished(data)

signal change(num,crewType)

# Called when the node enters the scene tree for the first time.
func _ready():

	player_check()
	for node in 4:
		var n = Select.instance()
		var _error = connect("change",n,"_on_PlayerSelectArea_change")
		$WFpanel/fullbox/Control.add_child(n)
		n.spotnum = $WFpanel/fullbox/Control.get_child_count() -1
		if n.spotnum > 0:
			n.hide()
		
		$WFpanel/fullbox/Control.get_child(node).rect_size.x = $WFpanel/fullbox/Control.rect_size.x / 4
		if node > 0:
			$WFpanel/fullbox/Control.get_child(node).rect_position.x = $WFpanel/fullbox/Control.get_child(node-1).rect_position.x+$WFpanel/fullbox/Control.get_child(node-1).rect_size.x
		$WFpanel/fullbox/Control.get_child(node).rect_size.y = $WFpanel/fullbox/Control.rect_size.y 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func player_add(_characterName,CharacterData):
	var fullname = WayFinder.generate_name()
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
	if len(players) >= 2:
		$WFpanel/fullbox/hint.text ="Press and hold Enter to Begin Mission"
	elif len(players) < 2:
		$WFpanel/fullbox/hint.text ="2 or more players needed to begin the game"
		
		
func _input(event):
	if visible:
		print(event.as_text())
		
		if !selecting: 
			if event.is_action_pressed("ui_accept") and len(players) < 4:
				if len(playersReady) == len(players):
					$WFpanel/fullbox/Control.get_child(len(players)).select()
					players.append({"input":"keyboard"})
					selecting = true
				else:
					print("player ",len(players)," Not locked in")
		else:
			if len(players) <= 4 and len(players) > len(playersReady):
					$WFpanel/fullbox/Control.get_child(len(playersReady)).lock_in()
					playersReady.append({"player":len(players)})
					player_add("nobody",availableClasses[classShown])
					player_check()
					selecting = false
			else:
				if !holding:
					$holdcount.start()
					holding = true
				
#	if visible and event.is_pressed():
#		
#		match event.get_scancode_with_modifiers():
#			KEY_SPACE:
#				if len(players) < 4:
#					if len(playersReady) == len(players):
#						$WFpanel/fullbox/Control.get_child(len(players)).select()
#						players.append({"input":"keyboard"})
#						selecting = true
#					else:
#						print("player ",len(players)," Not locked in")
#					
#			KEY_ENTER:
#				if len(players) <= 4 and len(players) > len(playersReady):
#					$WFpanel/fullbox/Control.get_child(len(playersReady)).lock_in()
#					playersReady.append({"player":len(players)})
#					player_add("nobody",availableClasses[classShown])
#					player_check()
#					selecting = false
#				else:
#					if !holding:
#						$holdcount.start()
#						holding = true
#			
#			KEY_LEFT:
#				if selecting == true:
#					if classShown > 0:
#						classShown -= 1
#						emit_signal("change",len(players),availableClasses[classShown])
#					else:
#						classShown = len(availableClasses)-1
#						emit_signal("change",len(players),availableClasses[classShown])
#			KEY_RIGHT:
#				if selecting == true:
#					if classShown < len(availableClasses)-1:
#						classShown += 1
#						emit_signal("change",len(players),availableClasses[classShown])
#					else:
#						classShown = 0
#						emit_signal("change",len(players),availableClasses[classShown])
					
#	else:
#		holding = false
#		held = 0
#		player_check()
#		$holdcount.stop()
	pass

func _on_PlayerSelect_resized():
	$Timer.start()
	pass # Replace with function body.


func _on_Timer_timeout():
	$Timer.stop()
	for node in $WFpanel/fullbox/Control.get_child_count():
		if node > 0:
			$WFpanel/fullbox/Control.get_child(node).rect_position.x = $WFpanel/fullbox/Control.get_child(node-1).rect_position.x+$WFpanel/fullbox/Control.get_child(node-1).rect_size.x
		$WFpanel/fullbox/Control.get_child(node).rect_size.x = $WFpanel/fullbox/Control.rect_size.x / 4
		$WFpanel/fullbox/Control.get_child(node).rect_size.y = $WFpanel/fullbox/Control.rect_size.y 


func _on_holdcount_timeout():
	if held == 3:
		WayFinder.gamesettings["players"] = len(players)
		WayFinder.emit_signal("startGame",WayFinder.gamesettings)
	else:
		held += 1
		$WFpanel/fullbox/hint.text ="Holding Enter ("+str(4-held)+")"


func _on_PlayerSelect_visibility_changed():
	if visible:
		for classes in WayFinder.classes:
			availableClasses.append(classes)
		$AnimationPlayer.playback_speed = 1.5
		$AnimationPlayer.play("Show")
