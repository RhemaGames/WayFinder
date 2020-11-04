extends Control

# warning-ignore:unused_signal
signal finished()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var info = "A: 23h 06m 29.283s\nD: −05° 02′ 28.59\n\nV:18.798±0.082\nR:16.466±0.065\nI:14.024±0.115\nJ:11.354±0.022\nH:10.718±0.021\nK:10.296±0.023"

# Called when the node enters the scene tree for the first time.
func _ready():
	$WFpanel/MarginContainer/HBoxContainer/RichTextLabel.bbcode_text = info
	$WFpanel/MarginContainer/HBoxContainer/RichTextLabel/AnimationPlayer.play("appear")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_trapist9info_finished():
	pass # Replace with function body.
