extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_hp(_num,data):
	var inclass = data["data"].instance()
	var info= inclass.get_info()
	$Control/HP.text = str(info["hp"])
