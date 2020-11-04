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

func from_Above(data):
	#print(data)
	if data[0] == "player" and data[1] == "hit":
		$AnimationPlayer.play("hit")
	if data[0] == "timer" and data[1] == "start":
		pass
		#self.count = 10
		#print("Starting Timer at: ",count)
