extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var percentShown = 0
var theText = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(_anim_name):
	sayit()
	#$AnimationPlayer.play("appear")
	pass # Replace with function body.

func clear():
	percentShown = 0
	hide()

func sayit():
	self.text = ""
	show()
	scroll_to_line(0)
	$Timer.start()
	
func _on_Timer_timeout():
	if percentShown < len(theText):
		self.text += theText[percentShown]
		percentShown +=1
		self.percent_visible = percentShown
	else:
		percentShown = 0
		$Timer.stop()
	
