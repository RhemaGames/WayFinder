extends Node


var Board = preload("res://scenes/Board.tscn")
var Battle #preload("res://packs/mission1/scenes/BattleGround.tscn")

var currentView
var battleView
var music_fade = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if first_load() == 1:
		#$shipBridge/Pilot/Camera.make_current()
		currentView = Board.instance()
		#battleView = Battle.instance()
# warning-ignore:return_value_discarded
		WayFinder.connect("combat_start",self,"_combat_mode")
# warning-ignore:return_value_discarded
		WayFinder.connect("startGame",self,"_on_start_game")
		
		var _error = $Preface.connect("done",self,"on_preface_done")
		
		#$shipBridge/Viewport/Menu/Main/Control/AnimationPlayer.play("Show")
		#add_child(battleView)
		$Audio/BGM.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if music_fade == true:
		if $Audio/BGM.volume_db > -20:
			$Audio/BGM.volume_db -= 0.5
		else:
			$Audio/BGM.stop()
			music_fade = false

func _on_start_game(_data):
	WayFinder.currentView = currentView
	$BG.hide()
	$Settings.hide()
	$FirstLoad.hide()
	$AutoSaveLoad.hide()
	battleView = WayFinder.currentMission.load_battleGround().instance()
	battleView.connect("battle_over",self,"_on_battle_over")
	battleView.connect("battle_over",currentView,"_on_battle_over")
	battleView.connect("battle_start",currentView,"_on_battle_start")
	$View.add_child(currentView)
	$View.add_child(battleView)
	$View.get_child(1).hide()
	$MapView/ViewportContainer/Viewport/InterpolatedCamera.transform = currentView.get_node("boardBacking/FullBoard").transform
	$shipBridge.hide()
	$shipBridge.queue_free()
	$Pselect.hide()
	$Pselect.queue_free()
	$PlayerSelect.hide()
	$PlayerSelect.queue_free()
	$Title.hide()
	

func _combat_mode(_Player,_Enemy):
	$View.get_child(0).hide()
	$View.get_child(1).show()
	battleView.combatant1 = _Player
	battleView.combatant2 = _Enemy
	battleView.emit_signal("battle_start")
	
func _on_battle_over(_combatant1,_combatant2):
	$View.get_child(0).show()
	$View.get_child(1).hide()
	if _combatant2 in currentView.enemies:
		print("Enemy Lost!")
	if _combatant1 in currentView.enemies:
		print("Enemy Won!")
	WayFinder.step_complete("combat")

func first_load():
	$FirstLoad.show()
	$AutoSaveLoad.show()
	var settings = load_settings()
	if init_settings(settings) == 1:
		if load_characters() == 1:
			load_waypoints()
	$FirstLoad.hide()
	$AutoSaveLoad.hide()
	return 1

func load_waypoints():
	var file = File.new()
	var directory = Directory.new()
	var path = "./packs/waypoints/" 
	if directory.open(path) == OK:
		directory.list_dir_begin(true,true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				var mission = ""
				if file.file_exists(path+file_name+"/MissionBriefing.tscn"):
					mission = load(path+file_name+"/MissionBriefing.tscn")
					var m = mission.instance()
					var info = m.get_info()
					#if typeof(player) == TYPE_OBJECT:
					WayFinder.waypoints.append({"folder":file_name,"title":info["title"],"missions":info["missions"],"about":info["about"],"screens":info["screens"]})
					m.queue_free()
			file_name = directory.get_next()
	else:
		print("An error occurred when trying to access the path.")
		return 0
	return 1
	
func load_characters():
	var file = File.new()
	var directory = Directory.new()
	var path = "./packs/characters/" 
	if directory.open(path) == OK:
		directory.list_dir_begin(true,true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				var player = ""
				if file.file_exists(path+file_name+"/"+file_name+".tscn"):
					player = load(path+file_name+"/"+file_name+".tscn")
					var p = player.instance() 
					var info = p.get_info()
					#if typeof(player) == TYPE_OBJECT:
					WayFinder.classes.append({"class":info["class"],"data":player})
					p.queue_free()
			file_name = directory.get_next()
	else:
		print("An error occurred when trying to access the path.")
		return 0
	return 1

func load_settings():
	var settings = WayFinder.settings 
	var file = File.new()
	var path = "user://settings.json"
	
	if file.file_exists(path):
		file.open(path, File.READ)
		var content = file.get_as_text()
		file.close()
		var parsed = parse_json(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			settings = parsed
		else:
			save_settings(settings)
	else:
		save_settings(settings)
	return settings

func save_settings(data):
	var file = File.new()
	var path = "user://settings.json"
	var output = "{"
	file.open(path, File.WRITE)
	#print(data)
	for c in data.keys():
		match typeof(data[c]):
			TYPE_BOOL:
				output += '"'+c+'":'+str(data[c]).to_lower()
			TYPE_STRING:
				output += '"'+c+'":"'+str(data[c])+'"'
			TYPE_ARRAY:
				output += '"'+c+'":'+str(data[c])
			TYPE_INT:
				output += '"'+c+'":'+str(data[c])
		if len(output) > 1:
			output +=","
			
	output = output.substr(0,len(output)-1)+"}"
	file.store_string(output)
	file.close()
	return 1

func init_settings(data):
	#print("initalizing settings:",data)
	#OS.window_fullscreen = data["fullscreen"]
	#OS.window_fullscreen = true
	#OS.window_size = Vector2(data["resolution"][0],data["resolution"][1])
	AudioServer.set_bus_volume_db(1,data["sfx_volume"])
	AudioServer.set_bus_volume_db(2,data["music_volume"])
	return 1

func show(item):
	match item:
		"settings":
			$Settings/AnimationPlayer.play("Show")

func player_select():
	$shipBridge.hide()
	$Title.hide()
	$Pselect.show()

func on_preface_done():
	music_fade =true
