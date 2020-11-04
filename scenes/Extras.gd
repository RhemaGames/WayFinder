extends Control

var Root
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Back_pressed():
	reset()
	hide()
	pass # Replace with function body.


func _on_Credits_pressed():
	reset()
	$Main/Credits.appear()
	pass # Replace with function body.


func _on_Species_pressed():
	reset()
	pass # Replace with function body.


func _on_Systems_pressed():
	reset()
	pass # Replace with function body.


func _on_Vechiles_pressed():
	reset()
	pass # Replace with function body.


func _on_Equip_pressed():
	reset()
	pass # Replace with function body.


func _on_Crew_pressed():
	reset()
	$Main/Crew.show()
	pass # Replace with function body.

func reset():
	$Main/Crew.hide()
	$Main/Credits.hide()
	
