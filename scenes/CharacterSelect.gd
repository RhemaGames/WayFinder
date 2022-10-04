extends Spatial

var classes = []
var showing = 0
signal changed_class(data)
# warning-ignore:unused_signal
signal player_selected(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	gather_classes()
	var start_class = classes[showing]["data"].instance()
	$Position3D.add_child(start_class)
	emit_signal("changed_class",start_class.get_info())
# warning-ignore:return_value_discarded
	WayFinder.connect("game_start",self,"_on_game_start")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#$Position3D.rotate_y(0.003)
	pass

func gather_classes():
	classes.append(WayFinder.classes[0])
	classes.append(WayFinder.classes[1])
	classes.append(WayFinder.classes[2])
	classes.append(WayFinder.classes[3])
	
	
	
func change_class(direction):
	if len(classes) > 0:
		var classInstances = $Position3D.get_child(0)
		$Position3D.remove_child(classInstances)
		classInstances.queue_free()
	
		if showing < len(classes) -1 and showing >= 0:
			showing += direction
		else:
			showing = 0
		var new_class = classes[showing]["data"].instance()
		$Position3D.add_child(new_class)
		emit_signal("changed_class",new_class.get_info())


func _on_CharacterSelect_player_selected(_data):
	classes.remove(showing)
	change_class(0)
	pass # Replace with function body.

func _on_game_start():
#	var preGameStart = $Position3D.get_child(0)
#	$Position3D.remove_child(preGameStart)
#	preGameStart.queue_free()
	hide()
