extends Control

var selected = false
var classInfo 
var spotnum = 0

var command1 = preload("res://packs/characters/Commander/assets/Tex_skill_35.PNG")
var command2 = preload("res://packs/characters/Commander/assets/Tex_skill_94.PNG")
var command3 = preload("res://packs/characters/Commander/assets/Tex_skill_13.PNG")

var commands = [{
	"name":"Double Time",
	"type":"general",
	"cost":2,
	"discription":"Once issued all alleys get a 2x multiplier to their movement rolls",
	"effect":{"target":["ally","all"],"view":"ActionView","when":"command","movement":"x2","duration":1},
	"icon": command1
},{
	"name": "Rally",
	"type":"general",
	"cost":3,
	"discription": "Gives all alleys a +2 to combat rolls",
	"effect":{"target":["ally","all"],"view":"ActionView","when":"command","combatRoll":2,"duration":1},
	"icon": command2
},{
	"name": "Called Shot",
	"type":"general",
	"cost":2,
	"discription":"During combat players get increased range on targets in combat with Commander",
	"effect":{"target":["ally","all"],"view":"ActionView","when":"command","range":3,"duration":1},
	"icon": command3
}]

var command_item = preload("res://scenes/Command.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	#$WFpanel/MarginContainer/Control/hint.text = "Space bar to begin."
	$Overlay/Control/Join.text = "Player "+str(spotnum+1)+"\nJoin Game"
	$WFpanel/MarginContainer/interface.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Timer_timeout():
	if !selected:
		if $Overlay/Control/Join.visible:
			$Overlay/Control/Join.hide()
		else:
			$Overlay/Control/Join.show()
		pass

func lock_in():
	selected = true
	spotnum += 1
	$Overlay.show()
	$Overlay/Control/Join.show()
	$WFpanel/MarginContainer/interface.hide()
	$Overlay/Control/Join.text = "Player "+str(spotnum)+"\nJoin Game"
	if spotnum > 2:
		$Overlay/Control/Hint.text = "Hold Enter to start game"
	else:
		$Overlay/Control/Hint.text = "Two players are required to play the game"
	#$Timer.stop()

func select():
	$Timer.stop()
	$Overlay.hide()
	$WFpanel/MarginContainer/interface.show()
	$WFpanel/MarginContainer/Control/hint.text = "Enter to lock in."
	#_on_PlayerSelectArea_change(spotnum+1,get_node("../../../../").availableClasses[0])
	_on_PlayerSelectArea_change(spotnum,get_node("../../../../").availableClasses[0])
	
	
func _on_Update_Info(data):
	$WFpanel/MarginContainer/interface/Class.text = data["class"]
	classInfo = data
	var commandList = $WFpanel/MarginContainer/interface/ScrollContainer/Commands
	
	while commandList.get_child_count() > 0:
		var itemInstance = commandList.get_child(commandList.get_child_count()-1)
		commandList.remove_child(itemInstance)
		itemInstance.queue_free()
		
	for i in data["commands"]:
		var command = command_item.instance()
		command.set_info([i["name"],i["discription"],i["icon"]])
		commandList.add_child(command)


func _on_ScrollContainer_resized():
	var place = $WFpanel/MarginContainer/interface/ScrollContainer/Commands
	for child in place.get_children():
		child.rect_size.x = place.rect_size.x

func _on_PlayerSelectArea_change(_num,crewType):
	var classInstance = crewType["data"].instance()
	_on_Update_Info(classInstance.get_info())
