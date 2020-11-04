extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var border = true
export var bg_opacity = 1.00
export var border_color = Color(1,1,1)
export var cover = false
export var hFlip = false
export var vFlip = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if border == true:
		$wrapAround.show()
	else:
		$wrapAround.hide()
	
	$wrapAround.self_modulate = border_color
	
	$Border.self_modulate = Color(1,1,1,bg_opacity)
	
	if cover == true:
		$cover.show()
	else:
		$cover.hide()
	
	if hFlip:
		$Border.flip_h = true
	
	if vFlip:
		$Border.flip_v = true
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_WFpanel_resized():
	pass # Replace with function body.


