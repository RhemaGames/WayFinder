extends Spatial

signal react(type)
signal finish(type)

var command1 = preload("res://packs/characters/Medic/assets/Tex_skill_89.PNG")
var command2 = preload("res://packs/characters/Medic/assets/Tex_skill_94.PNG")
var command3 = preload("res://packs/characters/Medic/assets/Tex_skill_68.PNG")

var animQueue = []
var shields = false

var weapon = preload("res://packs/characters/gun1.glb")
var lazerbeam = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_retro_laser_beam_002_44337.mp3.ogg")
var shield = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_droning_pulsating_force_field_25225.mp3.ogg")

var theme = "res://packs/characters/Medic/assets/PLPSF-Synth_Arpeggiator_Root_Note_A_028.wav"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var commands = [{
	"name":"Stabilize",
	"type":"general",
	"cost":2,
	"discription":"Heal one player by one hp to get them moving again",
	"effect":{"target":["ally","self"],"view":"Targetting","when":"command","hp":1,"duration":1,"canMove":true,"canAttack":true,"down":false},
	"icon": command1
},{
	"name": "Tranquilize",
	"type":"combat",
	"cost":1,
	"discription": "Enemy combatants can no longer attack or move for 2 rounds",
	"effect":{"target":"enemy","view":"special","when":"combat","canMove":false,"canAttack":false,"duration":2},
	"icon":command2
},{
	"name": "Full Heal",
	"type":"general",
	"unlock":"fullheal",
	"cost":3,
	"discription":"Restores player of all conditions and heals all damage",
	"effect":{"target":"ally","view":"Targetting","when":"command","hp":"full","canMove":true,"canAttack":true,"down":false},
	"icon":command3
}]
var hp = 3

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	$Medic/AnimationPlayer.connect("animation_finished",self,"do_stuff")
	animQueue.append("onBaseMedic")
	pass # Replace with function body.

func _process(_delta):
	if !$Medic/AnimationPlayer.is_playing() and len(animQueue) > 0:
		if $Medic/AnimationPlayer.has_animation(animQueue[0]):
			$Medic/AnimationPlayer.play(animQueue[0])

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
			animQueue.append("startMedic")
		"melee":
			animQueue.append("meleeMedic")
		"range":
			$Timer.start()
			$sfx.stream = lazerbeam
			animQueue.append("rangedMedic")
		"hit":
			animQueue.append("hitMedic")
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
			animQueue.append("winMedic")
			shields = false
		"loss":
			animQueue.append("lossMedic")
			shields = false

func do_stuff(anim_name):
	if anim_name == "ranged":
		$laserbolt.emitting = false
		$sfx.stop()
	if anim_name == "block":
		emit_signal("react","block")
	if anim_name == "rangedMedic":
		emit_signal("react","ranged")
	if anim_name == "meleeMedic":
		emit_signal("react","melee")
	if anim_name == "winMedic":
		emit_signal("finish","win")
	if anim_name == "lossMedic":
		emit_signal("finish","loss")
		
	animQueue.remove(0)


func _on_Timer_timeout():
	$laserbolt.emitting = true
	$sfx.play()
	$Timer.stop()
	pass # Replace with function body.
