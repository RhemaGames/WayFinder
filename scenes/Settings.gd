extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Root

# Called when the node enters the scene tree for the first time.
func _ready():
	Root = get_tree().get_root().get_node("com_ve_wayfinder")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Cancel_pressed():
	$AnimationPlayer.play_backwards("Show")
	pass # Replace with function body.


func _on_Save_pressed():
	var data = WayFinder.settings
	if Root.save_settings(data) == 1:
		$AnimationPlayer.play_backwards("Show")
	
	pass # Replace with function body.
