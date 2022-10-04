extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var oncard = ""
# warning-ignore:unused_signal
signal defeat()

signal react(type)
signal finish(type)

var inCombat = false

var animQueue = []
var shields = false
var lazerbeam = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_retro_laser_beam_002_44337.mp3.ogg")
var shield = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_droning_pulsating_force_field_25225.mp3.ogg")

var info = {
	"maxHp":3,
	"hp":3,
	"canMove":true,
	"canAttack":true
}

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	$Enemy1/AnimationPlayer.connect("animation_finished",self,"do_stuff")
	var _error = WayFinder.connect("enviroment_turn",self,"ai")
	#$AudioStreamPlayer.play()
	pass # Replace with function body.

func _process(_delta):
	if !$Enemy1/AnimationPlayer.is_playing() and len(animQueue) > 0:
		if $Enemy1/AnimationPlayer.has_animation(animQueue[0]):
			$Enemy1/AnimationPlayer.play(animQueue[0])

func _on_defeat():
	queue_free()

func action(act):
	match act:
		"start":
			$sfx.play()
			animQueue.append("start")
		"melee":
			animQueue.append("melee")
			pass
		"range":
			$Timer.start()
			$sfx.stream = lazerbeam
			animQueue.append("ranged")
		"hit":
			animQueue.append("hit")
			pass
		"block":
			$sfx.stream = shield
			animQueue.append("block")
			shields = true
			$sfx.play()
		"drop":
			animQueue.append("deflect")
			shields = false
			$sfx.stop()
		"win":
			shields = false
			animQueue.append("win")
		"loss":
			shields = false
			animQueue.append("loss")

func do_stuff(anim_name):
	if anim_name == "ranged":
		$laserbolt.emitting = false
		$sfx.stop()
	animQueue.remove(0)
	
	if anim_name == "block":
		emit_signal("react","block")
	if anim_name == "ranged":
		emit_signal("react","ranged")
	if anim_name == "melee":
		emit_signal("react","melee")
	if anim_name == "win":
		emit_signal("finish","win")
	if anim_name == "loss":
		emit_signal("finish","loss")


func _on_Timer_timeout():
	$laserbolt.emitting = true
	$sfx.play()
	$Timer.stop()




func ai():
	
	var attack = false
	var move = false
	var distance = 0
	if info["canAttack"]:
		randomize()
		if round(rand_range(0,1)) == 1:
			attack = true
		else:
			attack = false
			
	if info["canMove"]:
		randomize()
		distance = WayFinder.roll_dice()
		move = true
		
	if attack:
		if $RayCast.is_colliding():
			print($RayCast.get_collider().name)
	
	if move:
		randomize()
		var possible_paths = []
		if get_parent().name == "Board":
			if len(WayFinder.map) > 5:
				possible_paths = WayFinder.mark_path(self,distance)
				WayFinder.clear_path()
				var end = possible_paths[round(rand_range(0,len(possible_paths)-1))]
				var final_path = WayFinder.new_path(self.oncard,end["card"],distance)
				#print("Final path = ",final_path)
				translation = final_path[len(final_path)-1]["card"].available_point()["location"]
				rotation_degrees.y =  final_path[len(final_path)-1]["card"].rotation_degrees.y
