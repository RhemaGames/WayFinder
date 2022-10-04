extends Spatial

signal react(type)
signal finish(type)

var command1 = preload("res://packs/characters/Engineer/assets/Tex_skill_51.PNG")
var command2 = preload("res://packs/characters/Engineer/assets/Tex_skill_65.PNG")
var command3 = preload("res://packs/characters/Engineer/assets/Tex_skill_94.PNG")

var animQueue = []
var shields = false

var weapon = preload("res://packs/characters/gun1.glb")
var lazerbeam = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_retro_laser_beam_002_44337.mp3.ogg")
var shield = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_droning_pulsating_force_field_25225.mp3.ogg")

#var theme = "res://packs/characters/Engineer/assets/PLPSF-Mixed_Beat_120_20.wav"

var commands = [{
	"name":"Reroute",
	"type":"special",
	"cost":1,
	"discription":"Damaged system is restored for one round",
	"effect":{"target":"card","when":"command","view":"Targetting","eventtype":"engineering","event":"paused","duration":1},
	"icon": command1
},{
	"name": "Repair",
	"type":"general",
	"cost":2,
	"discription": "Fixes damaged system for good.",
	"effect":{"target":"card","when":"command","view":"","eventtype":"engineering","event":"fixed","duration":99},
	"icon": command2
},{
	"name": "Sabotage",
	"type":"general",
	"cost":3,
	"discription":"The engineer purposely breaks something to impeed the progress of everyone on the board",
	"effect":{"target":"card","when":"command","view":"","eventtype":"engineering","event":"new","duration":99},
	"icon": command3
}]

var hp = 6

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	$Engineer/AnimationPlayer.connect("animation_finished",self,"do_stuff")
	animQueue.append("deflect")
	animQueue.append("onBaseEngineer")
	#$Engineer/AnimationPlayer.play("onBaseEngineer")
	#$Engineer/AnimationPlayer.play("deflect")
	pass # Replace with function body.


func _process(_delta):
	if !$Engineer/AnimationPlayer.is_playing() and len(animQueue) > 0:
		if $Engineer/AnimationPlayer.has_animation(animQueue[0]):
			$Engineer/AnimationPlayer.play(animQueue[0])
		
func get_info():
	var data = {
		"class":name,
		"hp": hp,
		"commands":commands
	}
	return data

func action(act):
	match act:
		"start":
			animQueue.append("startEngineer")
			#$Commander/AnimationPlayer.play("start")
		"melee":
			animQueue.append("melee")
			#$Commander/AnimationPlayer.play("melee")
		"range":
			$Timer.start()
			$sfx.stream = lazerbeam
			animQueue.append("rangedEngineer")
			#$Commander/AnimationPlayer.play("ranged")
		"hit":
			animQueue.append("hitEngineer")
			#$Commander/AnimationPlayer.play("hit")
		"block":
			$sfx.stream = shield
			animQueue.append("block")
			shields = true
			$sfx.play()
			#$AnimationPlayer.block("block")
		"drop":
			animQueue.append("deflect")
			shields = false
			$sfx.stop()
		"win":
			animQueue.append("winEngineer")
			shields = false
		"loss":
			animQueue.append("lossEngineer")
			shields = false

func do_stuff(anim_name):
	if anim_name == "ranged":
		$laserbolt.emitting = false
		
		$sfx.stop()
		
	if anim_name == "block":
		emit_signal("react","block")
	if anim_name == "rangedEngineer":
		emit_signal("react","ranged")
	if anim_name == "meleeEngineer":
		emit_signal("react","melee")
	if anim_name == "winEngineer":
		emit_signal("finish","win")
	if anim_name == "lossEngineer":
		emit_signal("finish","loss")
		
	animQueue.remove(0)

func _on_Timer_timeout():
	$laserbolt.emitting = true
	$sfx.play()
	$Timer.stop()
	pass # Replace with function body.
