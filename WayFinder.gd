extends Node


# warning-ignore:unused_signal
signal startGame(data)

# warning-ignore:unused_signal
signal game_start()
# warning-ignore:unused_signal
signal turn_ended(turn)
signal turn_start(player)
# warning-ignore:unused_signal
signal step_completed(stepName)
signal game_over(reason)

# warning-ignore:unused_signal
signal place_cards(cardNum)
# warning-ignore:unused_signal
signal move_player(num)
# warning-ignore:unused_signal
signal trigger_event()
# warning-ignore:unused_signal
signal issue_command()
# warning-ignore:unused_signal
signal combat_round()

signal combat_start(thePlayer,theEnemy)

signal event_changed()

signal unlocked(crewClass,unlock)

signal movementType(change)

signal enviroment_turn()

var mType = "Standard"

var currentMission = "none"
var currentWayPoint = "none"

var waypoints = []
var classes = []

var deck = []
var used = []

var player = preload("res://scenes/Player.tscn")
var players = []
var commands = []
var events = []
var turn = 0
var theround = 0
var npc = []

var currentView
var deckstack

var player_location = []
var player_full_path = []
var npc_location = []

var screen_textures = []

var modifers = []

var placing = 0
var movement = 0

var mainEvent = 0

var mainEventFound = false

var names = []
var surnames = []

var board = ""

var settings = {
	"music_volume":-24,
	"sfx_volume":-6,
	"resolution":[1366,768],
	"fullscreen":false
}

var gamesettings = {
	"players":2,
	"waypoint":"none",
	"mission":"none"
}

var gamedata = {}

var map = []

func set_mainEvent(num):
	mainEvent += num
	emit_signal("event_changed")
	#return mainEvent

# Called when the node enters the scene tree for the first time.
func _ready():
	fill_names()
	load_game_data()
	
# warning-ignore:return_value_discarded
	connect("turn_ended",self,"_on_turn_ended")
# warning-ignore:return_value_discarded
	connect("startGame",self,"_on_startGame")
	#currentView = Board.instance()
	#add_child(currentView)
	pass # Replace with function body.


func _on_startGame(data):
	board = get_tree().get_root().get_node("com_ve_wayfinder").currentView
	if load_waypoint(data["waypoint"]) == 1:
		deckstack = currentWayPoint.deckstack 
		emit_signal("movementType","Standard")

func roll_dice(sides = 6):
	randomize()
	var roll = int(rand_range(1,sides))
	return roll
	
# warning-ignore:unused_argument
func get_player(player_num):
	var _player = {
		"num":0,
		"name":"Guest",
		"type":"Commander"
	}
	return _player
	
# warning-ignore:unused_argument
func set_player(data):
	players.append()
	pass

# warning-ignore:unused_argument
func get_command_list(player_type):
	var _commands = []
	#match player_type:
	#	"Commander":
	#		print("Commands")
	#	"Medic":
	#		print("Medic")
	#	"Security":
	#		print("Security")
	#	"Engineer":
	#		print("Engineer")
	return _commands

func shuffle_deck(_deckstack):
	var t = 0
	var line = 0
	var cross = 0
	var right = 0
	var left = 0
	var _events = 0
	var cp = 0
	var encounters = 0
	
	var unshuffled = []
	var encounterShuffle = []
	var eventShuffle = []
	var cpShuffle = []
	
	if "T" in _deckstack:
		t = _deckstack["T"]
	if "line" in _deckstack:
		line = _deckstack["line"]
	if "cross" in _deckstack:
		cross = _deckstack["cross"]
	if "left" in _deckstack:
		left = _deckstack["left"]
	if "right" in _deckstack:
		right = _deckstack["right"]
	if "cp" in _deckstack:
		cp = _deckstack["cp"]
	if "encounter" in _deckstack:
		encounters = _deckstack["encounter"]
	if "events" in _deckstack:
		_events = _deckstack["events"]
	
	var decksize = t+left+right+line+cross
	var cardnum = 0
	while cardnum < decksize:
		var card = {}
		card["location"] = "card"
		
		if t > 0:
			card["type"] = "T"
			t -= 1
		elif line > 0:
			card["type"] = "line"
			line -= 1
		elif cross > 0:
			card["type"] = "cross"
			cross -=1
		elif left > 0:
			card["type"] = "left"
			left -= 1
		elif right > 0:
			card["type"] = "right"
			right -= 1
			
		unshuffled.append(card)
		cardnum += 1
	randomize()
	unshuffled.shuffle()
	cardnum = 0
	while cardnum < decksize:
		if cp > 0:
			unshuffled[cardnum]["cp"] = true
			cp -= 1
		else:
			unshuffled[cardnum]["cp"] = false
		cpShuffle.append(unshuffled[cardnum])
		cardnum += 1
	
	randomize()
	cpShuffle.shuffle()
	cardnum = 0
	while cardnum < decksize:
		if _events > 0:
			randomize()
			var event_type = rand_range(1,5)
			cpShuffle[cardnum]["event"] = int(event_type)
			_events -= 1
		else:
			cpShuffle[cardnum]["event"] = 0
			
		eventShuffle.append(cpShuffle[cardnum])	
		
		cardnum += 1
	
	randomize()
	eventShuffle.shuffle()
	cardnum = 0
	cardnum = 0
	while cardnum < decksize:
		if encounters > 0:
			eventShuffle[cardnum]["encounter"] = true
			encounters -= 1
		else:
			eventShuffle[cardnum]["encounter"] = false
			
		encounterShuffle.append(eventShuffle[cardnum])	
		
		cardnum += 1
		
	randomize()
	encounterShuffle.shuffle()
	deck = encounterShuffle
	
	return 1
	
func fill_names():
	var firstname = File.new()
	firstname.open("res://assets/baby-names.csv", File.READ)
	names = firstname.get_as_text().split("\n")
	firstname.close()
	var lastname = File.new()
	lastname.open("res://assets/surnames.csv", File.READ)
	surnames = lastname.get_as_text().split("\n")
	lastname.close()

func generate_name():
	
	randomize()
	var names_array = Array(names)
	var surname_array = Array(surnames)
	names_array.shuffle()
	surname_array.shuffle()
	var fixlast = surname_array[0].split(",")[0][0]+surname_array[0].split(",")[0].to_lower().substr(1,-1)
	var fname = names_array[0].split(",")[1].split('"')[1]
	var lname = fixlast
	var sex = names_array[0].split(",")[3].split('"')[1]
	return {
		"name":fname,
		"surname":lname,
		"sex":sex
	}
	
func get_character_class(name):
	for c in classes:
		if c["class"] == name:
			return c["data"].instance()

func game_round():
	
	board = get_tree().get_root().get_node("com_ve_wayfinder").currentView
	board.get_node("Camera").make_current()
	if turn == len(players):
		if len(board.enemies) > 0:
			emit_signal("enviroment_turn")
			theround +=1
			turn = 1
			emit_signal("turn_start",turn)
		else:
			theround +=1
			turn = 1
			emit_signal("turn_start",turn)
			#print("Player ", turn,"'s turn")
	else:
		turn += 1
		emit_signal("turn_start",turn)
		#print("Player ", turn,"'s turn")
		
	#var enemies = enemy_detection(board.players[turn -1])
	
	#if len(enemies) == 0:
	#	board.players[turn - 1].inCombat = false
	#	return
	#else:
	#	board.players[turn - 1].inCombat = true
	#	emit_signal("combat_start",board.players[turn -1],enemies[0])
	emit_signal("enviroment_turn")
	
	#game_check()
	pass

func _on_turn_ended():
	for opt in players[turn-1].turnSteps:
		players[turn-1].turnSteps[opt] = false

	if game_check() == 0:
		game_round()
	
func game_check():
	board = get_tree().get_root().get_node("com_ve_wayfinder").currentView
	
	if mainEvent == currentMission.main_events+1:
		emit_signal("game_over",1)
		return 1
		
	var down = 0
	
	for p in board.players:
		if !p.info["canMove"] and !p.info["canAttack"]:
			print(p.info["class"]," is down")
			down += 1
	
	if len(board.players) == down:
		emit_signal("game_over",1)
		return 1
		
	for p in board.players:	
		if check_event_crew(p.info["class"],mainEvent) != -1:
			if !p.info["canMove"] and !p.info["canAttack"]:
				emit_signal("game_over",1)
				return 1
		else:
			break
			
	return 0
	
func step_complete(step):
		#var board = get_tree().get_root().get_node("com_ve_wayfinder").currentView
		var thePlayer = players[turn -1]
		
		if step != "combat" and thePlayer.inCombat == true:
			players[turn-1].turnSteps["build"] = true
			players[turn-1].turnSteps["move"] = true
			players[turn-1].turnSteps["event"] = true
			players[turn-1].turnSteps["command"] = true
			clear_path()
		else:
			match step:
				"build":
					clear_path()
					players[turn-1].turnSteps["build"] = true
					movement = roll_dice()
					if movement > len(map):
						movement = len(map)
					emit_signal("move_player",movement)
					emit_signal("step_completed","build")
				"move":
					players[turn-1].turnSteps["move"] = true
					emit_signal("trigger_event")
					if players[turn-1].turnSteps["build"] == false:
						emit_signal("step_completed","move")
				"event":
					clear_path()
					if(thePlayer.moving == false):
						players[turn-1].turnSteps["event"] = true
						emit_signal("issue_command")
						emit_signal("step_completed","event")
				"command":
					clear_path()
					players[turn-1].turnSteps["command"] = true
					emit_signal("step_completed","command")
					emit_signal("combat_round")
					
				"combat":
					clear_path()
					players[turn-1].turnSteps["combat"] = true
					thePlayer.inCombat = false
					emit_signal("step_completed","combat")
					emit_signal("turn_ended")
					

func make_path(startObject,endObject):
	clear_path()
	#print("Making Path")
	#var path = []
	var path1 = []
	#var path2 = []
	#var card_path = []
	
# warning-ignore:unused_variable
	var startpoint = Vector3(0,0,0)
	
	if typeof(startObject.oncard) == TYPE_STRING:
		startpoint = map[0]["card"].translation
	else:
		startpoint = startObject.oncard.translation
	
	var start = true
	var end = true

	if start and end:
		path1 = new_path(startObject.oncard,endObject,movement)

	
	for place in path1:
		place["card"].get_node("path_marker").show()

	return path1
	
	
func recursive_backtrace(cards,endpoint):
	var trace = []
	var pcard = endpoint["parent"]
	for i in cards:
		if ["card"] == null:
			break
		elif i["card"] == pcard:
			trace.append(i)
			pcard = i["parent"]
			for f in recursive_backtrace(cards,i):
				var found = false
				if f["card"] != null:
					for t in trace:
						if t["card"] == f["card"]:
							found = true
							break
				if !found:
					trace.append(f)
	return trace
	
func new_path(start,end,distance):
	# In the begining we collect all possible cards between start and end based on distance
	var all_cards = []
	var paths = start.get_paths(start)
	all_cards.append({"connector":0,"card":start,"parent":null})
	
	if len(paths) > 0:
	#	var card_found = false
		for card in paths:
			if !card in all_cards:
				all_cards.append(card)
				for i in recursive_path(card["card"],distance-1):
					var found = false
					for f in all_cards:
						#print("f = ",f["card"]," VS ","i = ",i["card"])
						if f["card"] == i["card"]:
							found = true
							break
					if !found:
						all_cards.append(i)
									
	# We initalize the final_path with the first index of all cards knowing this will always be the players position
	var final_path = []
	var s2e_path = []
	
	# lets make an array of paths using cotiguous cards using the starting point as "base"
	
	var startpaths = []
	
	# Gather start positions
	
	for i in all_cards:
		if i["parent"] == all_cards[0]["card"] :
			var begin = [all_cards[0],i]
			var found = false
			for st in startpaths:
				if st[1]["card"] == begin[1]["card"]:
					found = true
					break
			if !found:
				startpaths.append(begin)
				
				
	# Gather end points
	
	var endpoints = []
	
	for i in all_cards:
		var found = false
		for p in all_cards:
			if p["parent"] == i["card"]:
				found = true
				break
		if !found:
			endpoints.append(i)
			
	#print("End points =",len(endpoints)) 
	
	# Now we make an array of backtracks to the player from the end points
	
	var backtracks = []
	
	for e in endpoints:
		var trace = [e]
		if e["card"] != null:
			for f in recursive_backtrace(all_cards,e):
				trace.append(f)
			
		backtracks.append(trace)
		
	for b in backtracks:
		var startfound = false
		var endfound = false
		for s in b:
			if s["card"] == start:
				startfound = true
			if s["card"] == end:
				endfound = true
	
		if startfound and endfound:
			#print("found both begining and end in: ",b)
			s2e_path = b
			break
		
	s2e_path.invert()
	
	for i in s2e_path:
		final_path.append(i)
		if i["card"] == end:
			break

	#print(final_path)
	
	return final_path
	

func mark_path(_player,distance):
	clear_path()
	var final_path = []
	player_full_path = []
	var root = _player.oncard
	var paths = root.get_paths(root)
	final_path.append({"connector":0,"card":root})
	if len(paths) > 0:
		for card in paths:
			if !card in final_path:
				final_path.append(card)
			for i in recursive_path(card["card"],distance-1):
				var found = false
				for f in final_path:
					if f["card"] == i["card"]:
						found = true
						break
				if !found:
					final_path.append(i)
	
	player_full_path = final_path
	
	#print(len(player_full_path))
	
	for tcard in player_full_path:
		
			if tcard["card"] and tcard["card"] != _player.oncard:
				tcard["card"].get_node("path_marker").show()
			
	return final_path
	
func recursive_path(card,distance):
	var subpath = []
	if card:
		var paths = card.get_paths(card)
		if distance > 0:
			if len(paths) > 0: 
				for subcard in paths:
					if !subcard in subpath:
						subpath.append(subcard)
					for i in recursive_path(subcard["card"],distance-1):
						var found = false
						for f in subpath:
							if f["card"] == i["card"]:
								found = true
								break
						if !found:
							subpath.append(i)
			else:
				distance = 0
	return subpath
		

func clear_path():
	for card in map:
		card["card"].get_node("path_marker").hide()

func pathit(thecard):
	#print("Using Path It")
	var outofpoints = false
	var findPoint = thecard
	var pathToBegining = []
	#pathToBegining.append(findPoint.translation+thecard.available_point()["location"])
	pathToBegining.append(findPoint.translation)
	while !outofpoints:
			var found = false
			for point in map:
				if str(findPoint) in str(point["card"]):
					if point["parent"].translation != Vector3(0,0,0):
						#pathToBegining.append(point["parent"].translation+point["parent"].available_point()["location"])
						pathToBegining.append(point["parent"].translation)
					else:
						found = false
						break
					findPoint = point["parent"]
					found = true
					break
				else:
					found = false
			if found == false:
				outofpoints = true
				
	return pathToBegining

func enemy_detection(_player):
	var inRange = []
	#var board = get_tree().get_root().get_node("com_ve_wayfinder").currentView
	#var player_location = ""
	if _player.info["canAttack"]:
		if len(map) > 4:
			#player_location = map[0].card
			#if typeof(player.oncard) == TYPE_OBJECT:
				#player_location = player.oncard
	
			for enemy in board.enemies:
				for card in map:
					if str(enemy.oncard) == str(card["card"]):
						for c in map:
							if str(_player.oncard) == str(card["card"]):
								if str(enemy.oncard) == str(card["parent"]):
									if inRange.find(enemy) == -1:
										inRange.append(enemy)
							if str(_player.oncard) == str(card["parent"]):
								if str(enemy.oncard) == str(card["card"]):
									if inRange.find(enemy) == -1:
										inRange.append(enemy)
					
	return inRange

func load_waypoint(data):
	var file = File.new()
	var path = "./packs/waypoints/"
	if file.file_exists(path+data+"/MissionBriefing.tscn"):
		var waypoint = load(path+data+"/MissionBriefing.tscn")
		currentWayPoint = waypoint.instance()
		return 1
	else:
		return 0

func load_game_data():
	var default_data = {
		"unlocked":[
			{"waypoint":"Trapist 1","mission":"Arrival"}
		],
		"classes":[
			{"class":"Medic","reference":"00000"},
			{"class":"Security","reference":"00000"},
			{"class":"Engineer","reference":"00000"},
			{"class":"Commander","reference":"00000"}
		]
	}
	var file = File.new()
	var path = "user://game.dat"
	if file.file_exists(path):
		file.open(path,File.READ)
		var data = file.get_var()
		if typeof(data) == TYPE_DICTIONARY:
			gamedata = data
	else:
		save_game_data(default_data)
		gamedata = default_data
	pass

func save_game_data(data):
	
	var file = File.new()
	var path = "user://game.dat"
	file.open(path, File.WRITE)
	file.store_var(data)
	file.close()
	pass

func load_player_data():
	pass

func save_player_data():
	pass

func check_event_map(event):
	var ready = false
	if len(WayFinder.map) >= currentMission.get_main_event(event)["requires"]["mapsize"]:
		ready = true
	else: 
		ready = false
	return ready
	
func check_event_crew(crewMember,event):
	var ready = 0
	var needed = currentMission.get_main_event(event)["requires"]["crew"]
	if needed == "":
		ready = -1
	elif needed == crewMember:
		ready = 1
	else:
		ready = 0
		
	return ready
	
func check_event_location(location,event):
	var ready = false
	if location == currentMission.get_main_event(event)["requires"]["location"]:
		ready = true
	else: 
		ready = false
	return ready

func parse_command(data):
	
	print("Parsing Command")

	#var board = get_tree().get_root().get_node("com_ve_wayfinder").currentView
	var thePlayer = board.players[turn -1]	
	var theTarget
	var theCost = 0
	var theSignal = ""
	
	for key in data.keys():
		match key:
			"effect":
				for effect in data[key]:
					match effect:
						"target": 
							match data[key][effect]:
								"card":
									theTarget = thePlayer.oncard
						"event":
							theSignal = data[key][effect]
			"cost":
				theCost = data[key]
				
	if theTarget:
		if theCost <= thePlayer.info["cp"]:
			if theSignal:
				if theTarget.command(theSignal) == 1:
					thePlayer.info["cp"] -= theCost

func get_map_ends():
	var ends = []
	for card in map:
		var found = false
		for parent in map:
			if card["card"] == parent["parent"]:
				found = true
				
		if found == false:
			ends.append(card)

	return ends
