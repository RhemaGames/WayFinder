extends Control


#signal skipped
# warning-ignore:unused_signal
signal roll

var characterStat = preload("res://scenes/PlayerControlStat.tscn")
var commandIcon = preload("res://scenes/CommandIcon.tscn")

var Root

# Called when the node enters the scene tree for the first time.
func _ready():
	Root = get_tree().get_root().get_node("com_ve_wayfinder")
	var _error = get_tree().connect("screen_resized",self,"on_root_resized")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_root_resized():
	
	print("resized")

func _on_Roll_pressed():
	hide()
	get_parent().get_node("Commands").show()
	#emit_signal("roll")
	


func _on_PlayerControlsEndTurn_pressed():
	self.hide()
	WayFinder.step_complete("command")
	

func player_controls_update(player):
	var info = player.info
	#$PlayerControls.show()
	var commands = $CommandBlock/Commands/HBoxContainer
	var stats = $Stats/MarginContainer/VBoxContainer
	var general = $GeneralInfo/MarginContainer
	
	#var board = Root.currentView

	general.get_node("VBoxContainer/Name").text = info["name"]
	general.get_node("VBoxContainer/PlayerNum").text = "Player " + str(WayFinder.turn)
	
	while stats.get_child_count() > 0:
		var statsInstance = stats.get_child(stats.get_child_count()-1)
		stats.remove_child(statsInstance)
		statsInstance.queue_free()
		
	for stat in player.info:
		match stat:
			"class":
				var classstat = characterStat.instance()
				classstat.get_node("HBoxContainer/Label").text = player.info["class"]
				stats.add_child(classstat)
			"hp":
				var hpstat = characterStat.instance()
				hpstat.get_node("HBoxContainer/Label").text = "HP : "+str(player.info["hp"])
				stats.add_child(hpstat)
			"cp":
				var hpstat = characterStat.instance()
				hpstat.get_node("HBoxContainer/Label").text = "CP : "+str(player.info["cp"])
				stats.add_child(hpstat)
			"level":
				var hpstat = characterStat.instance()
				hpstat.get_node("HBoxContainer/Label").text = "Level : "+str(player.info["level"])
				stats.add_child(hpstat)	
	
	while commands.get_child_count() > 0:
		var commandsInstance = commands.get_child(commands.get_child_count()-1)
		commands.remove_child(commandsInstance)
		commandsInstance.queue_free()
	
	for command in player.commands:
		var icon = commandIcon.instance()
		icon.set_texture(command["icon"])
		commands.add_child(icon)
	
	if player.inCombat == true:
		WayFinder.step_complete("event")



func _on_PlayerControls_visibility_changed():
	if visible:
		player_controls_update(get_parent())
		
	pass # Replace with function body.
