extends RigidBody


export var SPEED = 0.05
var Root

var UITemplate = preload("res://scenes/gui_panel_3d.tscn")
var board
var inCombat = false
var type
var model
var placementOffset = Vector3(0,0,0)
var charactername
var playernum

var commands
var command_index = -1
var general_commands = []

var thepath = []
var pathcords = []
var moving = false
var oncard = "start"
var map = []


var movement = 0
var cardinfo = {
	"type":"none",
	"event":0,
	"cp":false,
	"encounter":false
	}

var info = {
	"name":"Player Name",
	"class":"Commander",
	"level":1,
	"maxHp":3,
	"hp":3,
	"canMove":true,
	"canAttack":true,
	"unlocks":[]
}

var turnSteps = {
	"build":false,
	"move":false,
	"event":false,
	"command":false,
	"combat":false,
}

# warning-ignore:unused_signal
signal loadup(data)

signal ability_check()

signal command()

# Called when the node enters the scene tree for the first time.
func _ready():
	Root = get_tree().get_root().get_node("com_ve_wayfinder")
	$Commands.hide()
	$SpeechBox.hide()
	if Root != null:
		board = Root.currentView
	
# warning-ignore:return_value_discarded
	var _error = WayFinder.connect("move_player",self,"_on_player_move")
	_error = WayFinder.connect("unlocked",self,"on_unlock")
	_error = connect("command",WayFinder,"parse_command")
	_error = WayFinder.connect("movementType",self,"on_movementType_change")
	_error = WayFinder.connect("turn_start",self,"_on_turn_start")
	on_movementType_change(WayFinder.mType)
	
	$CameraBoom/Movement/CP.update_internal({"type":"background","value":Color(0.07451, 0.239216, 0.305882,0.5)})
	$CameraBoom/Movement/Modifers.update_internal({"type":"background","value":Color(0.07451, 0.239216, 0.305882,0.5)})
	$CameraBoom/Movement/HealthDisplay.update_internal({"type":"background","value":Color(0.07451, 0.239216, 0.305882,0.5)})
	$CameraBoom/Movement/CP.update_internal({"type":"font_shadow","value":Color(0.039216, 0.419608, 0.564706,1)})
	$CameraBoom/Movement/Modifers.update_internal({"type":"font_shadow","value":Color(0.039216, 0.419608, 0.564706,1)})
	$CameraBoom/Movement/HealthDisplay.update_internal({"type":"font_shadow","value":Color(0.039216, 0.419608, 0.564706,1)})

func execute_command():
	
	pass

func load_commands():
	var card = "res://scenes/CommandCard.tscn"
	var cardNum = 0
	var OffSet = 2
	
	for c in commands:
		if c["type"] == "general" and c["unlock"] == "":
			var theCard = UITemplate.instance()
			theCard.UI = card
			theCard.handle_input = true
			theCard.connect("relay",self,"on_card_ready",[theCard,c])
			theCard.resolution = Vector2(500,800)
			theCard.ratio = 4
			#theCard.scale = Vector3(0.6,0.7,0.6)
			$Commands.add_child(theCard)
			theCard.translate_object_local(Vector3(2.5*cardNum-OffSet,0,0))
			cardNum += 1
			if !c in general_commands:
				general_commands.append(c)
	pass

func on_card_ready(_data,theCard,c):
	theCard.get_node("Viewport").get_child(0).playerRoot = self
	theCard.get_node("Viewport").get_child(0).load_card(c)
	theCard.get_node("Viewport").get_child(0).connect("execute",self,"on_command_execute")
	var _error = connect("ability_check",theCard.get_node("Viewport").get_child(0),"_on_check_abilities")
	

func _on_Player_loadup(data):
	model = WayFinder.get_character_class(data.info["class"])
	commands = model.commands
	info["hp"] = model.get_info()["hp"]
	info["maxHp"] = model.get_info()["hp"]
	info["class"] = data.info["class"]
	
	## Remove this at a later date
	#$Audio/Theme.stream = load(model.theme)
	#$Audio/Theme.play()
	# ^^^
	
	load_commands()
	update_cp_count()
	$Model.add_child(model)
	
	if data.info["class"] == "Engineer":
		var puzzle = load("res://packs/waypoints/trappist-1/scenes/Activities/Repair.tscn").instance()
		puzzle.connect("success",self,"_on_Repair_success")
		$Puzzle.add_child(puzzle)

func _on_player_move(num):
	if str(get_parent().players[WayFinder.turn -1]) == str(self):
		WayFinder.mark_path(self,num)
	
func update_position(path):
	movement = WayFinder.movement + 1
	thepath = path
	moving = true
	if info["canMove"]:
		$CameraBoom/Movement.make_current()
		toggle_UI("show")
		
		if $Model.get_child(0).get_child(0).get_node("AnimationPlayer").has_animation("walk_legs"):
			$Model.get_child(0).get_child(0).get_node("AnimationPlayer").play("walk_legs")
		else:
			$AnimationPlayer.playback_speed = 1.5
			$AnimationPlayer.play("move")
			
	else:
		$Model.rotation_degrees(90,0,0)
		thepath = []
		moving = false
		movement_over()

var xdistance = 1
var zdistance = 1

var lastx = transform.origin.x
var lastz = transform.origin.z

# warning-ignore:unused_argument
func _physics_process(delta):

	if movement == 0 and moving == true:
		moving = false
		thepath = []
		movement_over()
		
	if len(thepath) > 0:
		var currentcord = thepath[0]["card"].available_point()["location"]
		if thepath[0]["parent"] == null:
			currentcord = global_transform.origin
		
		if $Model.get_child(0).get_child(0).get_node("AnimationPlayer").has_animation("walk_legs"):
			if !$Model.get_child(0).get_child(0).get_node("AnimationPlayer"):
					$Model.get_child(0).get_child(0).get_node("AnimationPlayer").play("walk_legs")
		else:
			if !$AnimationPlayer.is_playing():
				$AnimationPlayer.play("move")

		if translation.x == currentcord.x and translation.z == currentcord.z:
			map.append(currentcord)
			movement -= 1
			thepath.remove(0)
			
			#if len(thepath) > 0:
			#	if lastx < get_global_transform().origin.x:
			#		$Model.rotation_degrees.y = 0
					#$CameraBoom.rotation_degrees.y = 0
			#	elif lastx > get_global_transform().origin.x:
			#		$Model.rotation_degrees.y = 180
			#		#$CameraBoom.rotation_degrees.y = 180
					
			#	if lastz < get_global_transform().origin.z:
			#		$Model.rotation_degrees.y = -90
					#$CameraBoom.rotation_degrees.y = -90
			#	elif lastz > get_global_transform().origin.z:
			#		$Model.rotation_degrees.y = 90
					#$CameraBoom.rotation_degrees.y = 90
					
			
		else:
			
			if len(thepath) > 0:
				
				var position_change = Vector3(stepify(lastx,0.0001) - stepify(transform.origin.x,0.0001),0,stepify(lastz,0.0001) - stepify(transform.origin.z,0.0001))
					
				if position_change.x > 0 and position_change.z > 0:
					pass
					if rotation_degrees.y in [0,-90,90]:
						$Model.rotation_degrees.y -= 1
					elif rotation_degrees.y == 180:
						$Model.rotation_degrees.y += 1
				elif position_change.x < 0 and position_change.z > 0:
					if rotation_degrees.y in [0,-90,90]:
						$Model.rotation_degrees.y += 1
					elif rotation_degrees.y == 180:
						$Model.rotation_degrees.y -= 1
						
				elif position_change.x > 0 and position_change.z < 0:
					if rotation_degrees.y in [0,-90,90]:
						$Model.rotation_degrees.y += 1
					elif rotation_degrees.y == 180:
						$Model.rotation_degrees.y -= 1
				elif position_change.x < 0 and position_change.z < 0:
					if rotation_degrees.y in [0,-90,90]:
						$Model.rotation_degrees.y -= 1
					elif rotation_degrees.y == 180:
						$Model.rotation_degrees.y += 1
				else:
					match str(position_change):
						
						"(-0.018, 0, 0)":
							match str(stepify(rotation.y,0.01)):
								"3.14":
									global_rotate(Vector3(0,1,0),-3.14)
								"1.57":
									global_rotate(Vector3(0,1,0),-1.57)
								"-1.57":
									global_rotate(Vector3(0,1,0),1.57)
								"0":
									global_rotate(Vector3(0,1,0),0)
									
						"(0.018, 0, 0)":
							match str(stepify(rotation.y,0.01)):
								"-3.14":
									global_rotate(Vector3(0,1,0),3.14)
								"1.57":
									global_rotate(Vector3(0,1,0),-1.57)
								"-1.57":
									global_rotate(Vector3(0,1,0),1.57)
								"0":
									global_rotate(Vector3(0,1,0),3.14)
									
						"(0, 0, -0.018)":
							if stepify(rotation.y,0.01) != -1.57:
								global_rotate(Vector3(0,1,0),-1.57)
								
						"(0, 0, 0.018)":
							if stepify(rotation.y,0.01) != 1.57:
								global_rotate(Vector3(0,1,0),1.57)

					$Model.rotation_degrees.y = 0

			lastx = transform.origin.x
			lastz = transform.origin.z
			
			if translation.x < currentcord.x:
				if currentcord.x - translation.x > SPEED:
					translation.x += SPEED
				else:
					translation.x = currentcord.x
			else:
				if  translation.x - currentcord.x > SPEED:
					translation.x -= SPEED
				else:
					translation.x = currentcord.x
				
			if  translation.z < currentcord.z:
				if  currentcord.z - translation.z > SPEED:
					translation.z += SPEED
				else:
					translation.z = currentcord.z
			else:
				if translation.z - currentcord.z > SPEED:
					translation.z -= SPEED
				else:
					translation.z = currentcord.z
					
			if len(thepath) == 1:
				var z_axis = -1*translation.z - -1*currentcord.z
				var x_axis = -1*translation.x - -1*currentcord.x
				if z_axis == 0 and x_axis == 0:
					if z_axis == 0 and x_axis == 0:
						moving = false
						movement_over()
						
			
	else:
		movement = 0

func _on_Area_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	
	if "card" in area.get_groups():
		cardinfo = area.get_parent().info
		var card_index = area.get_parent().get_index()
		oncard = area.get_parent().get_parent().get_child(card_index)
		WayFinder.emit_signal("trigger_event")
		if !area.get_parent().power:
			moving = false
			thepath = [thepath[0]]
			
		if cardinfo["cp"]:
			info["cp"] += 1
			update_cp_count()
		
	if "card" in area.get_groups() and moving == false:
		if on_step() == "move":
			movement_over()
		
		
func movement_over():
	toggle_UI("hide")
	if $Model.get_child(0).get_child(0).get_node("AnimationPlayer").has_animation("walk_legs"):
		$Model.get_child(0).get_child(0).get_node("AnimationPlayer").stop()
	else:
		$AnimationPlayer.stop()
	if on_step() == "move":
		WayFinder.step_complete("move")

func update_cp_count():
	$Audio/CP_Pickup.play()
	$CameraBoom/Movement/CP.update_internal({"type":"count","value":info["cp"]})
	$Audio/CP_Pickup.play()
	
func _on_CommandsCancelButton_pressed():
	$Commands.hide()
	$Commands/Control.hide()
	WayFinder.step_complete("command")
	Root.get_node("Menu/Click").play()
	
func on_command_execute(data):
	print(data)
	emit_signal("command",data)
	$Commands.hide()
	$Commands/Control.hide()
	if data["effect"].has("view"):
		if data["effect"]["view"] != "":
			print("Doing the thing!")
			get_parent().players[WayFinder.turn -1].get_node(data["effect"]["view"]).make_current()
	Root.get_node("Menu/Click").play()
	#$Command.show()
	$Puzzle.show()
	if $Puzzle.get_child_count() > 0:
		$Puzzle.get_child(0).new_puzzle()
		$Puzzle.get_child(0).get_node("Camera").make_current()
	

func _on_CommandCancel_pressed():
	$Command.hide()
	$Puzzle.hide()
	WayFinder.step_complete("command")
	Root.get_node("Menu/Click").play()

func on_unlock(_crewClass,unlocked):
	for ab in unlocked:
		if info["class"] == ab["who"]:
			info["unlocks"].append(ab["what"])
			emit_signal("ability_check")
			
func _on_Repair_success():
	#$Command.hide()
	$Puzzle.hide()
	oncard.command("fixed")
	WayFinder.step_complete("command")
	Root.get_node("Menu/Click").play()

func on_step():
	for step in turnSteps.keys():
		if turnSteps[step] == false:
			return step
		
func _on_Commands_visibility_changed():
	if visible:
		$Commands/Control.show()
	else:
		$Commands/Control.hide()
	pass
	
func on_movementType_change(changeTo):
	match changeTo:
		"Standard":
			pass
			
		"Caution":
			pass
			
		"Combat":
			pass
			


func _on_Player_body_shape_entered(_body_id, body, _body_shape, _local_shape):
	
	if "card" in body.get_groups():
		cardinfo = body.get_parent().info
		var card_index = body.get_parent().get_index()
		oncard = body.get_parent().get_parent().get_child(card_index)
		WayFinder.emit_signal("trigger_event")
		if !body.get_parent().power:
			moving = false
			thepath = [thepath[0]]
			
		if cardinfo["cp"]:
			info["cp"] += 1
			update_cp_count()
			
	if "card" in body.get_groups() and moving == false:
		movement_over()


func _on_PlayerArea_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	
	if "card" in area.get_groups():
		cardinfo = area.get_parent().info
		var card_index = area.get_parent().get_index()
		oncard = area.get_parent().get_parent().get_child(card_index)
		WayFinder.emit_signal("trigger_event")
		if !area.get_parent().power:
			moving = false
			thepath = [thepath[0]]
			
		if cardinfo["cp"]:
			info["cp"] += 1
			update_cp_count()

	if "card" in area.get_groups() and moving == false:
		movement_over()

func toggle_UI(display):
	if display == "show":
		$CameraBoom/Movement/HealthDisplay.show()
		$CameraBoom/Movement/Modifers.show()
		$CameraBoom/Movement/CP.show()
	else:
		$CameraBoom/Movement/HealthDisplay.hide()
		$CameraBoom/Movement/Modifers.hide()
		$CameraBoom/Movement/CP.hide()

func _on_turn_start(turn):

	if playernum+1 == turn:
		#print("showing Log for ",info.class)
		$SpeechBox.show()
		command_index = -1
	#else:
	#	$SpeechBox.hide()


func _input(event):
	if $SpeechBox.visible:
		
		if event.is_action_pressed("ui_cancel"):
			if WayFinder.players[WayFinder.turn-1].turnSteps["build"] == false:
				if WayFinder.placing == 0:
					WayFinder.emit_signal("place_cards",WayFinder.roll_dice())
			else:
				WayFinder.emit_signal("turn_ended")
			Root.get_node("Menu/Click").play()
			$SpeechBox.hide()
			
		if event.is_action_pressed("ui_accept"):
			## Need to add a generic signal relay to Wayfinder to make passing signals easier.
			pass
	
	if $Commands.visible: 
		if event.is_action_pressed("ui_cancel"):
			$Commands.hide()
			$Commands/Control.hide()
			WayFinder.step_complete("command")
			Root.get_node("Menu/Click").play()
		if event.is_action_pressed("ui_left"):
			## Switch to the left
			if command_index > 0:
				command_index -= 1
				WayFinder.emit_signal("relay",{"type":"command","index":command_index})
		if event.is_action_pressed("ui_right"):
			## Switch to the right
			if command_index < general_commands.size()-1:
				command_index += 1
				WayFinder.emit_signal("relay",{"type":"command","index":command_index})
		if event.is_action_pressed("ui_accept"):
			#print(general_commands[command_index])
			on_command_execute(general_commands[command_index])
