extends Control

var command_item = preload("res://scenes/Command.tscn")
#var characterStat = preload("res://scenes/PlayerControlStat.tscn")
var commandIcon = preload("res://scenes/CommandIcon.tscn")
var classInfo = ""

var Root

# warning-ignore:unused_signal
signal onLoad()
var menu = 0
var clash = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	Root = get_tree().get_root().get_node("com_ve_wayfinder")
	
	
	Root.get_node("Combat/AnimationPlayer").connect("animation_finished",self,"_on_Combat_AnimationPlayer_animation_finished")
# warning-ignore:return_value_discarded
	WayFinder.connect("turn_start",self,"_on_turn_start")
# warning-ignore:return_value_discarded
	WayFinder.connect("turn_ended",self,"_on_turn_ended")
# warning-ignore:return_value_discarded
	#WayFinder.connect("place_cards",self,"update_task",["place_cards"])
# warning-ignore:return_value_discarded
	#WayFinder.connect("move_player",self,"update_task",["movement"])
# warning-ignore:return_value_discarded
	WayFinder.connect("trigger_event",self,"query_event")
# warning-ignore:return_value_discarded
	WayFinder.connect("issue_command",self,"_on_issue_command")
# warning-ignore:return_value_discarded
	WayFinder.connect("combat_round",self,"_on_combat_round",["begin"])
	
# warning-ignore:return_value_discarded
	WayFinder.connect("combat_start",self,"_on_combat_start")
	
# warning-ignore:return_value_discarded
	#WayFinder.connect("step_complete",self,"_on_step_complete")
# warning-ignore:return_value_discarded
	WayFinder.connect("game_over",self,"_on_game_over")
	
# warning-ignore:return_value_discarded
	WayFinder.connect("startGame",self,"_on_gameStart")
	
	#$PlayerControls/CommandBlock/Roll.connect("pressed",self,"_on_Roll_pressed")
	
	#$PlayerControls/PlayerControlsEndTurn.connect("pressed",self,"_on_PlayerControlsEndTrun_pressed")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_gameStart(_data):
	#var charSelect = Root.currentView.get_node("Start/Start/characterSelectPoint/CharacterSelect")
	#charSelect.connect("changed_class",self,"_on_Update_Info")
	pass

func _on_Menu_onLoad():
	$Main/Control/AnimationPlayer.play("Show")
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	
	match anim_name:
		"Show":
			#$Main/Control/AnimationPlayer.play("MissionSelect")
			$Main/Control/AnimationPlayer.play("MainMenu")
		"NewGame":
			$Main/Control/AnimationPlayer.play("MissionSelect")
			
		"MissionSelect":
			if menu == 1:
				$Main/Control/AnimationPlayer.play("EncounterSelect")
		
		"EncounterSelect":
			if menu == 2:
				$Main/Control/AnimationPlayer.play("PlayerSelect")
		
	#if anim_name == "ShowInfo":
	#	print("Showing")
	#if anim_name == "HideInfo":
	#	print("Hiden")
		
	pass # Replace with function body.


func _on_Mission_pressed(data):
	menu = 1
	
	WayFinder.gamesettings["waypoint"] = data["folder"]
	$Main/Control/AnimationPlayer.play_backwards("MissionSelect")
	for m in data["encounters"]:
		var found = false
		var button = Button.new()
		button.text = m["title"]
		button.connect("pressed",self,"_on_Encounter_pressed",[m])
		for unlocked in WayFinder.gamedata["unlocked"]:
			if data["title"] == unlocked["mission"]:
				if m["title"] == unlocked["encounter"]:
						found = true
						break
		if !found:
			button.disabled = true
		else:
			button.disabled = false
			
		$Main/Control/Encounter/ScrollContainer/Encounters.add_child(button)
	$Click.play()


func _on_Encounter_pressed(data):
	menu = 2
	WayFinder.gamesettings["encounter"] = data["title"]
	WayFinder.currentMission = load(data["file"]).instance()
	WayFinder.currentMission.Root = get_tree().get_root().get_node("com_ve_wayfinder")
	$Main/Control/AnimationPlayer.play_backwards("EncounterSelect")
	$Click.play()


func _on_Menu_resized():
	#print(self.get_viewport_rect())
	pass # Replace with function body.

func _on_2players_pressed():
	WayFinder.gamesettings["players"] = 2
	WayFinder.emit_signal("startGame",WayFinder.gamesettings)
	$Main.hide()
	$Click.play()
	
func _on_3players_pressed():
	WayFinder.gamesettings["players"] = 3
	WayFinder.emit_signal("startGame",WayFinder.gamesettings)
	$Main.hide()
	$Click.play()


func _on_4players_pressed():
	WayFinder.gamesettings["players"] = 4
	WayFinder.emit_signal("startGame",WayFinder.gamesettings)
	$Main.hide()
	$Click.play()

func _on_back_pressed():
	Root.currentView.get_node("Start/Start").emit_signal("character_back")
	$Click.play()

func _on_next_pressed():
	Root.currentView.get_node("Start/Start").emit_signal("character_next")
	$Click.play()


func _on_CharacterSelect_visibility_changed():
	#if $CharacterSelect.visible:
		
	#	if len(WayFinder.players) == 0:
	#		_on_Update_Info(WayFinder.classes[0]["data"].instance().get_info())
	#		$CharacterSelect/WFpanel/MC/VBoxContainer/Player.text = "Player 1"
	#	else:
	#		$CharacterSelect/WFpanel/MC/VBoxContainer/Player.text = "Player " + str(len(WayFinder.players)+1)
			
	#	var fullname = WayFinder.generate_name()
	#	$CharacterSelect/WFpanel/MC/VBoxContainer/CharacterName.text = fullname["name"]+" "+fullname["surname"]
	#	$CharacterSelect/CharacterSelectAnimations.play("Show")
	pass

func _on_Update_Info(_data):
	#$CharacterSelect/WFpanel/MC/VBoxContainer/Class.text = data["class"]
	#classInfo = data
	#var commandList = $CharacterSelect/WFpanel/MC/VBoxContainer/ScrollContainer/CommandList
	
	#while commandList.get_child_count() > 0:
	#	var itemInstance = commandList.get_child(commandList.get_child_count()-1)
	#	commandList.remove_child(itemInstance)
	#	itemInstance.queue_free()
	#	
	#for i in data["commands"]:
	#	var command = command_item.instance()
	#	command.set_info([i["name"],i["discription"],i["icon"]])
	#	commandList.add_child(command)
	pass


func _on_RandomName_pressed():
	#var fullname = WayFinder.generate_name()
#	$CharacterSelect/WFpanel/MC/VBoxContainer/CharacterName.text = fullname["name"]+" "+fullname["surname"]
	#$Click.play()
	pass


func _on_CharacterSelectAccept_pressed():
#	var interface = $CharacterSelect/WFpanel/MC/VBoxContainer
#	var characterClass = interface.get_node("Class").text
#	var characterName = interface.get_node("CharacterName").text
	#var characterMap = {
	#	"class":characterClass,
	#	"name":characterName,
	#	"hp": classInfo["hp"],
	#	"cp": 1,
	#	"canMove":true,
	#	"canAttack":true,
	#	"level":1
	#}
#	var characterMap = WayFinder.player.instance()
#	characterMap.info["class"] = characterClass
#	characterMap.info["name"] = characterName
#	characterMap.info["maxHp"] = classInfo["hp"]
#	characterMap.info["hp"] = classInfo["hp"]
#	characterMap.info["cp"] = 1
#	characterMap.info["canMove"] = true
#	characterMap.info["canAttack"] = true
#	characterMap.info["level"] = 1
#	characterMap.info["unlocks"] = []
	
#	Root.currentView.get_node("Start/Start/characterSelectPoint/CharacterSelect").emit_signal("player_selected",characterClass)
	#var characterHp = interface.get_node("")
#	WayFinder.players.append(characterMap)
#	$CharacterSelect/CharacterSelectAnimations.play("Hide")
#	$Click.play()
	pass

func _on_CharacterSelectAnimations_animation_finished(_anim_name):
	#if anim_name == "Hide" and len(WayFinder.players) < WayFinder.gamesettings["players"]:
	#	$CharacterSelect/CharacterSelectAnimations.play("Show")
	
	#if len(WayFinder.players) == WayFinder.gamesettings["players"]:
	#	WayFinder.emit_signal("game_start")
		
	pass # Replace with function body.

func _on_turn_start(player):
	
	#var board = get_parent().get_parent()
	$PlayerChange/VBoxContainer/Name.text = WayFinder.players[player-1].info["name"]
	$PlayerChange/VBoxContainer/playerNum.text = "Player "+str(player)
	$PlayerChange/AnimationPlayer.play("Grow")
	#player_log(WayFinder.players[player-1].info["class"])
	pass

func _on_turn_ended():
	self.show()
	#var board = get_parent().get_parent()
	Root.get_node("MapView").set_task("")
	#$PlayerControls/CurrentTask/Label.text = ""	
	#$PlayerControls.hide()
	clash = false
	
	
	pass


func player_log(playerClass):
	var thelog = WayFinder.currentMission.get_crew_comment(playerClass,WayFinder.mainEvent)
	#var thelog = Root.currentView.Briefing.get_crew_comment(playerClass,WayFinder.mainEvent)
	#$CrewLog/WFpanel/MC/VBoxContainer/Title.text = thelog["title"]
	#$CrewLog/WFpanel/MC/VBoxContainer/RichTextLabel.theText = thelog["log"]
	#$CrewLog/AnimationPlayer.play("Show")
	pass

#func player_controls_update(player):
#	var info = WayFinder.players[player].info
	#$PlayerControls.show()
#	var commands = $PlayerControls/CommandBlock/Commands/HBoxContainer
#	var stats = $PlayerControls/Stats/MarginContainer/VBoxContainer
#	var general = $PlayerControls/GeneralInfo/MarginContainer
	
#	var board = Root.currentView

#	general.get_node("VBoxContainer/Name").text = info["name"]
#	general.get_node("VBoxContainer/PlayerNum").text = "Player " + str(player + 1)
	
#	while stats.get_child_count() > 0:
#		var statsInstance = stats.get_child(stats.get_child_count()-1)
#		stats.remove_child(statsInstance)
#		statsInstance.queue_free()
#		
#	for stat in WayFinder.players[player].info:
#		match stat:
#			"class":
#				var classstat = characterStat.instance()
#				classstat.get_node("HBoxContainer/Label").text = WayFinder.players[player].info["class"]
#				stats.add_child(classstat)
#			"hp":
#				var hpstat = characterStat.instance()
#				hpstat.get_node("HBoxContainer/Label").text = "HP : "+str(WayFinder.players[player].info["hp"])
#				stats.add_child(hpstat)
#			"cp":
#				var hpstat = characterStat.instance()
#				hpstat.get_node("HBoxContainer/Label").text = "CP : "+str(WayFinder.players[player].info["cp"])
#				stats.add_child(hpstat)
#			"level":
#				var hpstat = characterStat.instance()
#				hpstat.get_node("HBoxContainer/Label").text = "Level : "+str(WayFinder.players[player].info["level"])
#				stats.add_child(hpstat)	
	
#	while commands.get_child_count() > 0:
#		var commandsInstance = commands.get_child(commands.get_child_count()-1)
#		commands.remove_child(commandsInstance)
#		commandsInstance.queue_free()
	
#	for command in board.players[player].commands:
#		var icon = commandIcon.instance()
#		icon.set_texture(command["icon"])
#		commands.add_child(icon)
	
#	if board.players[player].inCombat == true:
#		WayFinder.step_complete("event")
		
#func update_task(num,task):
#	var board = Root.currentView
#	match task:
#		"place_cards":
#			$Rolls/VBoxContainer/Name.text = "Map Building"
#			$Rolls/VBoxContainer/info.text = "Place "+str(num)+" Cards"
#			$Rolls/AnimationPlayer.play("Grow")
#			Root.get_node("MapView").set_task("Place "+str(num)+" Cards")
#		"movement":
#			$Rolls/VBoxContainer/Name.text = "Move Piece"
#			$Rolls/VBoxContainer/info.text = "Move Piece up to "+str(num)+" places"
#			$Rolls/AnimationPlayer.play("Grow")
#			Root.get_node("MapView").set_task("Move Piece up to "+str(num)+" places")
#		"event":
#			$Rolls/VBoxContainer/Name.text = "Event!"
#			$Rolls/VBoxContainer/info.text = str(num)
#			$Rolls/AnimationPlayer.play("Grow")
#			$PlayerControls/CurrentTask/Label.text = "Event"
#		"commands":
#			$Rolls/VBoxContainer/Name.text = "Command"
#			$Rolls/VBoxContainer/info.text = "Issue Command"
#			$Rolls/AnimationPlayer.play("Grow")
#			$PlayerControls/CurrentTask/Label.text = "Issue Command"
#		"combat":
#			if board.players[WayFinder.turn -1].inCombat == true:
#				$Rolls/VBoxContainer/Name.text = "Combat Round"
#				$Rolls/VBoxContainer/info.text = "Pew Pew"
#				$Rolls/AnimationPlayer.play("Grow")
#				$PlayerControls/CurrentTask/Label.text = "Combat Round"
	
#func _on_PlayerControlsEndTurn_pressed():
#	WayFinder.emit_signal("turn_ended")
#	$Click.play()


func _on_Roll_pressed():
	$Click.play()
	
	if WayFinder.players[WayFinder.turn -1].turnSteps["build"] == false:
		if WayFinder.placing == 0:
			WayFinder.emit_signal("place_cards",WayFinder.roll_dice())
	elif WayFinder.players[WayFinder.turn -1].turnSteps["move"] == false:
		#print("movement")
		if WayFinder.movement == 0:
			WayFinder.emit_signal("move_player",WayFinder.roll_dice())
	#elif WayFinder.players[WayFinder.turn -1],turnSteps["event"] == false:
	#	print("event")
	#elif WayFinder.players[WayFinder.turn -1].turnSteps["command"] == false:
	#	print("Issue Command")
	#elif WayFinder.players[WayFinder.turn -1].turnSteps["combat"] == false:
	#	print("COMBAT!")
		
	pass # Replace with function body.


func _on_topMove_mouse_entered():
	pass # Replace with function body.

#func _on_step_complete():
#	if WayFinder.players[WayFinder.turn -1].turnSteps["build"] == true:
#		$Rolls/VBoxContainer/Name.text = "Building Phase"
#		$Rolls/VBoxContainer/info.text = "Complete"
#		$Rolls/AnimationPlayer.play("Grow")
#		$PlayerControls/CurrentTask/Label.text = ""

func query_event():
	var board = Root.currentView
	var info = {
		"type":"none",
		"event":0,
		"cp":false,
		"encounter":false
	}
	if typeof(board.players[WayFinder.turn -1].oncard) == TYPE_OBJECT:
		info = board.players[WayFinder.turn -1].oncard.info
		if board.players[WayFinder.turn -1].moving == false:
			if info["event"] == 4:
# warning-ignore:unused_variable
			#var test = WayFinder.set_mainEvent(1)
			#info["event"] = 0
				if WayFinder.check_event_location(info["location"],WayFinder.mainEvent):
					if WayFinder.check_event_crew(board.players[WayFinder.turn -1].info["class"],WayFinder.mainEvent) != 0:
						board.players[WayFinder.turn -1].oncard.get_node("Marker").hide()
						var eventInfo = WayFinder.currentMission.get_main_event(WayFinder.mainEvent)
						$MainEvent/WFpanel/MC/VBoxContainer/Title.text = eventInfo["title"]
						$MainEvent/WFpanel/MC/VBoxContainer/Discription.text  = eventInfo["log"]
						$MainEvent.show()
						WayFinder.game_check()
			
		if info["event"] != 0:
			WayFinder.step_complete("event")
		else:
			WayFinder.step_complete("event")
		

func _on_issue_command():

	var board = Root.currentView
	if board.players[WayFinder.turn -1].on_step() == 'command':
		board.players[WayFinder.turn -1].get_node("Commands").show()
		pass
	
	var data = board.players[WayFinder.turn -1].commands
	var cp = WayFinder.players[WayFinder.turn -1].info["cp"]
	$CommandView/PanelContainer2/HBoxContainer/CP.text = str(cp)
	var commandList = $CommandView/WFpanel/MC/VBoxContainer/ScrollContainer/CommandList
	
	while commandList.get_child_count() > 0:
		var itemInstance = commandList.get_child(commandList.get_child_count()-1)
		commandList.remove_child(itemInstance)
		itemInstance.queue_free()
		
	for i in data:
		var command = command_item.instance()
		command.set_info([i["name"],i["discription"],i["icon"]])
		command.connect("gui_input",self,"_on_command_issue_gui_input",[i["effect"],command])
		commandList.add_child(command)

func _on_command_issue_gui_input(event,effect,object):
	if event.is_pressed() and event.get_button_index() == 1:
			WayFinder.commands.append(effect)
			WayFinder.step_complete("command")
			$CommandView.hide()
			#update_task(0,"combat")
			$Click.play()
			
	if event.as_text().split(":")[0] == "InputEventMouseMotion ":
		object.get_node("Highlight").show()
	else:
		
		object.get_node("Highlight").hide()
	
	pass
	
func _on_combat_start(_thePlayer,_theEnemy):
	self.hide()
	
func _on_combat_end(_thePlayer):
	self.show()

func _on_combat_round(_action,_winner = ""):
	var combatView = Root.get_node("Combat")
	var board = Root.currentView
	var player = WayFinder.turn - 1
	var enemies = WayFinder.enemy_detection(board.players[player])
	
	if len(enemies) == 0:
		board.players[player].inCombat = false
		WayFinder.step_complete("combat")
		return
	else:
		board.players[player].inCombat = true
		
	if len(enemies) > 0:
		combatView.get_node("VBoxContainer/top/PlayerView/Label").text = WayFinder.players[player].info["name"]
		combatView.get_node("PlayerViewPort/Camera").set_target(Root.battleView.get_node("Player/load"))
		combatView.get_node("CombatantViewPort/Camera").set_target(Root.battleView.get_node("Enemy/load"))
		combatView.get_node("AnimationPlayer").play("Clash")
		WayFinder.emit_signal("combat_start",board.players[player],enemies[0])

	pass

func _on_Cancel_pressed():
	$Click.play()
	pass # Replace with function body.


func _on_CommandViewCancel_pressed():
	WayFinder.step_complete("command")
	$CommandView.hide()
	#update_task(0,"combat")
	$Click.play()
	pass # Replace with function body.


func _on_CrewLogContinue_pressed():
	#$CrewLog/AnimationPlayer.play_backwards("Show")
	#var player = WayFinder.turn -1
	#if Root.currentView.players[player].info["canMove"]:
		#player_controls_update(player)
	#if WayFinder.players[player].turnSteps["build"] == false:
	#	if WayFinder.placing == 0:
	#		WayFinder.emit_signal("place_cards",WayFinder.roll_dice())
	#else:
	#	WayFinder.emit_signal("turn_ended")
	#$Click.play()
	pass # Replace with function body.


func _on_MainEventContinue_pressed():
	$MainEvent.hide()
	if WayFinder.game_check() != 1:
		WayFinder.step_complete("event")
	$Click.play()
	pass # Replace with function body.

# warning-ignore:unused_argument
func _on_game_over(reason):
	$End.show()


func _on_Combat_AnimationPlayer_animation_finished(anim_name):
	var combatView = Root.get_node("Combat")
	if anim_name == "Clash" and clash == false:
		combatView.get_node("AnimationPlayer").play_backwards("Clash")
		clash = true
		
	#	_on_combat_round("rolls")
	#if anim_name == "EnemyWins":
	#	_on_combat_round("resolved")
	#if anim_name == "PlayerWins":
	#	_on_combat_round("resolved")
	#if anim_name == "Resolved":
	#	WayFinder.step_complete("combat")
	pass # Replace with function body.


func _on_MainMenu_New_Game_pressed():
	$Main/Control/AnimationPlayer.play("NewGame")
	for m in WayFinder.missions:
		var button = Button.new()
		button.text = m["title"]
		button.connect("pressed",self,"_on_Mission_pressed",[m])
		$Main/Control/Mission/ScrollContainer/Missions.add_child(button)
	$Click.play()
	pass # Replace with function body.


func _on_MainMenu_Settings_pressed():
	Root.show("settings")
	$Click.play()
	pass # Replace with function body.


func _on_MainMenu_Quit_pressed():
	get_tree().quit()
	$Click.play()
	pass # Replace with function body.


func _on_Store_pressed():
	$Click.play()
	pass # Replace with function body.


func _on_Extras_pressed():
	$Click.play()
	Root.get_node("Extras").show()
	pass # Replace with function body.


func _on_BacktoMain_pressed():
	pass # Replace with function body.


func _on_BackToMissions_pressed():
	pass # Replace with function body.
