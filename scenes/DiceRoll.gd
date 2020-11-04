extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# warning-ignore:unused_signal
signal pulse()
#signal zoomIn()
#signal zoomOut()

# Called when the node enters the scene tree for the first time.
func _ready():
	$roll.text = "?"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func pulse():
	$AnimationPlayer.play("Pulse")
	pass # Replace with function body.


func zoomIn():
	$AnimationPlayer.play("zoomIn")
	pass # Replace with function body.


func zoomOut():
	$AnimationPlayer.play("zoomOut")
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "zoomOut":
		$roll.text = "?"
		
	pass # Replace with function body.
