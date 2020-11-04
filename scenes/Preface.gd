extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var script_line = 0

signal done()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	change()
	script_line += 1
	pass # Replace with function body.

func change():
	match script_line:
		0:
			$Words.text = "Vague Entertainment\nPresents"
			$Timer.wait_time = 5
		1:
			$Words.text = "Dec. 22 2525"
			$Timer.wait_time = 3
		2:
			$Words.text = "It's 2525 and we're still alive."
			$Timer.wait_time = 10
		3:
			$Words.text = "Today marks the aniversery of the great converence. The moment we faced our greatest challenge. The moment that redefined who and what we were."
		4:	
			$Words.text = "It took decades of hard work and tragic losses, but the planet has known a lasting peace for hundreds of years"
			$Timer.wait_time = 5
		6:
			$Words.text = "It is a testement to our endurence, our spirit, and our better natures"
		7:
			$Words.text = "On this day we mark another pivotal moment in our combined history."
			$Timer.wait_time = 10
		8:
			$Words.text = "As a race, we broke the bonds that held us to the ground and made the first steps into space. Yet we were still caged, still confined to our own system"
		9: 
			$Words.text = "Now, as a collective, we have our first shot at braking free of that cage. To travel to other stars, other planets."
		10:
			$Words.text = "Our hearts, and our thoughts go with the crew of the first WayFinder class ship as it prepares to usher in a new era of interstellar travel..."
		11:
			$Words.text = "-- Admiral Johanthan Riggs."
			$Timer.wait_time = 3
		12:
			emit_signal("done")
			$Timer.stop()
			hide()
