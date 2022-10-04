extends Control

var ticked = preload("res://scenes/Tick.tscn")
var infoBlock = preload("res://scenes/infoblock.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cost = 1
var effect = {}
var fullEffect = {}
var locked = false
var skill = ""
signal execute(data)
# warning-ignore:unused_signal
signal display()
#signal finished(data)

var playerRoot = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	#playerRoot = get_parent().get_parent().get_parent()
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	
#	pass

func load_card(data):
	$MarginContainer/VBoxContainer/Name.text = data["name"]
	$MarginContainer/VBoxContainer/About.text = data["discription"]
	$CardIcon.texture = data["icon"]
	fullEffect = data
	cost = data["cost"]
	effect = data["effect"]
	if data.has("unlock"):
		skill = data["unlock"]
		if typeof(playerRoot) == TYPE_OBJECT:
			if data["unlock"] in playerRoot.info["unlocks"]:
				show()
				locked = false
			else:
				hide()
				locked = true
		else:
			hide()
			locked = true
	for e in data["effect"].keys():
		var newEffects = infoBlock.instance()
		if !e in ["view","duration","when"]:
			newEffects.get_node("Label").text = e+": "+str(data["effect"][e])
			$MarginContainer/VBoxContainer/Stats.add_child(newEffects)
	
	var cnum = 0
	while cnum < cost:
		$CP.add_child(ticked.instance())
		cnum +=1

func _on_CommandCard_gui_input(event):
	if event.is_pressed() and event.get_button_index() == 1:
		if get_parent().get_parent().get_parent().info["cp"] >= cost:
			get_parent().get_parent().get_parent().info["cp"] -= cost
			emit_signal("execute",fullEffect)
		else:
			print("not Enough CP for this Card")

func _on_check_abilities():
	if locked:
		if skill in playerRoot.info["unlocks"]:
			locked = false
			show()
		else:
			hide()


func _on_CommandCard_display():
	if get_parent().get_parent().get_parent().info["cp"] < cost:
		$AnimationPlayer.play("display")
	pass # Replace with function body.


func _on_CommandCard_mouse_entered():
	self.rect_scale = Vector2(1.1,1.1)
	get_parent().set("custom_constants/seperation",50)
	pass # Replace with function body.


func _on_CommandCard_mouse_exited():
	self.rect_scale = Vector2(1,1)
	get_parent().set("custom_constants/seperation",40)
	pass # Replace with function body.


func _on_CommandCard_finished(data):
	pass # Replace with function body.
