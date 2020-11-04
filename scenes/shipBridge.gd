extends Spatial
var opened = 0
var current = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Audio/ComputersRunning.play()
	$Audio/EngineSound.play()
	pass # Replace with function body.

func _process(_delta):
	if current <= opened:
		current += 0.0009
		$blastdoor1.translate(Vector3(0,-current,0))
		$blastdoor2.translate(Vector3(0,current,0))
	
	if current >= 0.01:
		#print("lights up")
		#$Light.show()
		$Light002.show()
		#$Light004.show()
		#$Light002.show()
	
	if current > 0.001:
		#print("lights up")
		#$Light.show()
		$Light001.show()
		#$Light004.show()
		#$Light001.show()
	

func open_BlastDoors():
	opened = 1
	$Particles.emitting = true
	$AudioStreamPlayer3D.play()
	$RightHullMonitor/GUIPanel3D.load_ui("res://scenes/2DUI/AutoPilot.tscn")
	$LeftHullMonitor/GUIPanel3D.load_ui("res://scenes/2DUI/Stasis.tscn")
	$Audio/Overlay1.play()


func _on_GUIPanel3D_finished(menu):
	if visible:
		if menu[0] == "Start":
			open_BlastDoors()
		if menu[0] == "NewLoad":
			if menu[1] == "new":
				$MainScreen/GUIPanel3D.load_ui("res://scenes/2DUI/WayPoint.tscn")
		if menu[0] == "WayPoint":
			if typeof(menu[1]) == TYPE_STRING:
				if menu[1] == "back":
					print(" WayPoint Going Back")
					$MainScreen/GUIPanel3D.load_ui("res://scenes/2DUI/NewLoad.tscn")
			else:
				WayFinder.gamesettings["waypoint"] = menu[1]["folder"]
				WayFinder.currentWayPoint = load("res://packs/waypoints/"+menu[1]["folder"]+"/MissionBriefing.tscn").instance()
				$MainScreen/GUIPanel3D.load_ui("res://scenes/2DUI/Mission.tscn")
			
		if menu[0] == "Mission":
			if typeof(menu[1]) == TYPE_STRING:
				if menu[1] == "back":
					print("Mission Going Back")
					$MainScreen/GUIPanel3D.load_ui("res://scenes/2DUI/WayPoint.tscn")
			else:
				WayFinder.gamesettings["mission"] = menu[1]["title"]
				WayFinder.currentMission = load(menu[1]["file"]).instance()
				WayFinder.currentMission.Root = get_tree().get_root().get_node("com_ve_wayfinder")
				get_parent().player_select()
				#WayFinder.emit_signal("startGame",WayFinder.gamesettings)
		
	pass # Replace with function body.


func _on_AudioStreamPlayer3D_finished():
	$MainScreen/GUIPanel3D.load_ui("res://scenes/2DUI/NewLoad.tscn")
	pass # Replace with function body.
