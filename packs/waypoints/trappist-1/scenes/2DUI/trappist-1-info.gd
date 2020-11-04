extends Control

# warning-ignore:unused_signal
signal finished()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var info = "TRAPPIST-1 is an ultra-cool dwarf star of spectral class M8.0±0.5 that is approximately 8% the mass of and 11% the radius of the Sun. Although it is slightly larger than Jupiter, it is about 84 times more massive.[32][11] High-resolution optical spectroscopy failed to reveal the presence of lithium,[33] suggesting it is a very low-mass main-sequence star, which is fusing hydrogen and has depleted its lithium, i.e., a red dwarf rather than a very young brown dwarf.[11] It has a temperature of 2,511 K (2,238 °C; 4,060 °F),[6] and its age has been estimated to be approximately 7.6±2.2 Gyr.[9] In comparison, the Sun has a temperature of 5,778 K (5,505 °C; 9,941 °F)[34] and an age of about 4.6 Gyr.[35] Observations with the Kepler K2 extension for a total of 79 days revealed starspots and infrequent weak optical flares at a rate of 0.38 per day (30-fold less frequent than for active M6–M9 dwarfs); a single strong flare appeared near the end of the observation period. The observed flaring activity possibly changes the atmospheres of the orbiting planets on a regular basis, making them less suitable for life.[7] The star has a rotational period of 3.3 days.[7][36]"

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
