extends Spatial

var pathmarker = preload(("res://scenes/marker.tscn"))
var marker = preload("res://scenes/EventCard.tscn")

var Briefing
var Player
var Combatant
var Cards
var bgm
var battleMusic

var players = []
var enemies = []
var markers = []
var unlocks = []

var Root 

var cameraLastPos = Vector3(0,0,0)
var cameraAtPos = "default"
signal camera_Position(target)
signal mapUpdate()
# Called when the node enters the scene tree for the first time.
func _ready():
	Player = WayFinder.player
	Root = get_tree().get_root().get_node("com_ve_wayfinder")
# warning-ignore:return_value_discarded
	WayFinder.connect("startGame",self,"_on_WayFinder_startGame")
# warning-ignore:return_value_discarded
	WayFinder.connect("game_start",self,"_on_game_start")
	$AnimationPlayer.play("fadein")
# warning-ignore:return_value_discarded
	#$Start/Start.connect("place",self,"place_card")
# warning-ignore:return_value_discarded
	WayFinder.connect("turn_start",self,"_on_turn_start")
# warning-ignore:return_value_discarded
	WayFinder.connect("place_cards",self,"build_map")
# warning-ignore:return_value_discarded
	WayFinder.connect("issue_command",self,"command_view")
# warning-ignore:return_value_discarded
	WayFinder.connect("trigger_event",self,"on_event")
# warning-ignore:return_value_discarded
	WayFinder.connect("unlocked",self,"on_unlock")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $Camera.get_target_path() != cameraAtPos:
		
		if (-1 * $Camera.translation) - (-1 * cameraLastPos) > Vector3(0.01,0.01,0.01):
			cameraLastPos = $Camera.translation
		else:
			cameraAtPos = $Camera.get_target_path()
			emit_signal("camera_Position",cameraAtPos)

func on_unlock(_crewclass,data):
	for d in data:
		if d["who"] == "Board":
			unlocks.append(d["what"])

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadein":
		_on_WayFinder_startGame(WayFinder.settings)

func _on_WayFinder_startGame(_data):
	
	WayFinder.shuffle_deck(WayFinder.deckstack)
	Combatant = WayFinder.currentMission.load_combatant()
	Cards = WayFinder.currentMission.load_cards()
	Briefing = WayFinder.currentMission
	bgm = WayFinder.currentMission.bgm3
	battleMusic = WayFinder.currentMission.battleMusic
	$BGM.stream = load(bgm)
	$BGM.play()
	place_card($Map.global_transform,$Map,"sleepbay")
	WayFinder.emit_signal("game_start")

func place_card(location,parent,type = "card"):
	if len(WayFinder.map) > 0 :
		find_end()
		
	if type == "card":
		var new_card = Cards.instance()
		if len(WayFinder.deck) > 0 and WayFinder.placing > 0:
			var card = WayFinder.deck[0]
			new_card.type = card["type"]
			if card["event"] == 4 or card["event"] == 2:
				if WayFinder.check_event_map(WayFinder.mainEvent):
					if WayFinder.check_event_location("card",WayFinder.mainEvent):
						var _error = WayFinder.connect("event_changed",new_card,"on_event_changed")
					#else:
						#print("requires a special location")
				else:
					#print("Map not big enough")
					card["event"] = 0
				
			new_card.info = card
			var fixed_origin = Vector3(stepify(location.origin.x,1),0.0,stepify(location.origin.z,1))
			new_card.set_transform(Transform(location.basis,fixed_origin))
			new_card.connect("place",self,"place_card")
			var dic_placement = {
				"card":new_card,
				"parent":parent
			}
			new_card.connect("placed",parent,"check_doors")
			WayFinder.map.append(dic_placement)
			$Map.add_child(new_card)
			WayFinder.used.append(WayFinder.deck[0])
			WayFinder.deck.remove(0)
			WayFinder.placing -= 1
			if WayFinder.placing == 0:
				WayFinder.step_complete("build")
		elif len(WayFinder.deck) == 0:
				WayFinder.step_complete("build")
	else:
		for area in WayFinder.currentMission.eventAreas:
			if type == area["name"]:
				var new_area = area["file"].instance()
				var fixed_origin = Vector3(location.origin.x,0.0,location.origin.z)
				new_area.set_transform(Transform(location.basis,fixed_origin))
				new_area.connect("place",self,"place_card")
				var dic_placement = {
					"card":new_area,
					"parent":parent
					}
				new_area.connect("placed",parent,"check_doors")
				WayFinder.map.append(dic_placement)
				$Map.add_child(new_area)
				new_area.on_add()
				print("New area in conflict: "+str(new_area.inConflict))
				
				break
				
	emit_signal("mapUpdate")

func _on_Board_camera_Position(target):
	var _target_path = target.get_name(target.get_name_count()-1).split("/")

func _on_game_start():
	#$Camera.make_current()
	$boardBacking/FullBoard.make_current()
	var count = 1
	for i in WayFinder.players:
		var location = $Map.get_child(0).get_node("p"+str(count)).global_transform
		i.oncard = $Map.get_child(0)
		count += 1
		place_players(location,i)
	WayFinder.game_round()
	
func _on_turn_start(player):
	#$Camera.make_current()
	players[player-1].get_node("ActionView").make_current()
	$boardBacking/AnimationPlayer.play("fadeout")
	
func _on_battle_over(winner,loser):
	print("From Board Battle over")
	if winner in enemies:
		print("Player incapasitated")
		loser.info["canMove"] = false
		loser.info["canAttack"] = false
		
	if loser in enemies:
		print("Enemy Lost, removing from board")
		var enemy_index = enemies.find(loser)
		enemies[enemy_index].queue_free()
		enemies.remove(enemy_index)
	$BGM.stream = load(bgm)
	$BGM.play()
	
func _on_battle_start():
	$BGM.stream = load(battleMusic)
	$BGM.play()
		
func place_players(location,data):
	data.set_transform(location)
	data.emit_signal("loadup",data)
	players.append(data)
	add_child(data)
	pass

func build_map(num):
	Root.get_node("MapView").show_map()
	$boardBacking/FullBoard.make_current()
	#for end in WayFinder.get_map_ends():
	#	end["card"].get_node("path_marker").show()
	#$Camera.set_target()
	if len(WayFinder.deck) > num:
		WayFinder.placing = num
	else:
		WayFinder.placing = len(WayFinder.deck)
		
func move_players(player,path):
	#$Camera.make_current()
	Root.get_node("MapView").hide_map()
	player.update_position(path)
	pass

func map_build(_num,_location,_parent,_connectionPoint):
	pass

func command_view():
	#$Camera.make_current()
	#$Camera.set_target()
	players[WayFinder.turn -1 ].get_node("ActionView").make_current()

func on_event():
	var card = players[WayFinder.turn -1].oncard
	var player = players[WayFinder.turn -1]
	
	var info = {
	"type":"T",
	"event":0,
	"cp":false,
	"encounter":false
}
	if typeof(card) !=TYPE_STRING:
		info = card.info
	
	var parent = ""
	var child = ""
	for point in WayFinder.map:
		if str(point["parent"]) == str(card):
			child = point["card"]
		if str(point["card"]) == str(card):
			parent = point["parent"]

	
	if !player.moving:
		if info["event"] == 4:
			var current_player = players[WayFinder.turn -1]
			var eventInfo = WayFinder.currentMission.get_main_event(WayFinder.mainEvent)
			if WayFinder.check_event_map(WayFinder.mainEvent):
				if WayFinder.check_event_location(current_player.oncard.info["location"],WayFinder.mainEvent):
					if WayFinder.check_event_crew(current_player.info["class"],WayFinder.mainEvent) != 0:
						if eventInfo["effect"]["add"] != "":
							if WayFinder.map[-1]["card"].get_node("Connectors/Connector1") != null:
								place_card(WayFinder.map[-1]["card"].get_node("Connectors/Connector1").global_transform,WayFinder.map[-1]["card"],eventInfo["effect"]["add"])
						if len(eventInfo["unlocks"]) != 0:
							WayFinder.emit_signal("unlocked",current_player.info["class"],eventInfo["unlocks"])
						info["event"] = 0
						WayFinder.set_mainEvent(1)
						
			randomize()
			
		if info["encounter"] and unlocks.has("enemies"):
			var combatant_instance = Combatant.instance()
			if parent.translation != Vector3(0,0,0):
				combatant_instance.set_scale(Vector3(0.5,0.5,0.5))
				var ends = WayFinder.get_map_ends()
				var whichend = 0
				if len(ends) > 1:
					whichend = round(rand_range(0,len(ends)-1))
				else:
					whichend = 0
					
				combatant_instance.translation = ends[whichend]["card"].translation + Vector3(0,1.8,0)
				combatant_instance.rotation_degrees.y =  ends[whichend]["card"].rotation_degrees.y
				combatant_instance.oncard = ends[whichend]["card"]
				enemies.append(combatant_instance)
				add_child(combatant_instance)
				#combatant_instance.ai()
				
			card.info["encounter"] = false

func find_end():
	WayFinder.map.invert()
	var _map_invert = WayFinder.map
	#for card in map_invert:
		#print(card["card"].name)
		#print(card["parent"].name)
		
	WayFinder.map.invert()
	pass
