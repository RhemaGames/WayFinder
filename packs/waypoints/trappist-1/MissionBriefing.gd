extends Node

var deckstack = {
	"T": 15,
	"line":15,
	"cross":15,
	"cp":20,
	"events":30,
	"encounter":10
}

var info = {
	"title":"Trappist 1",
	"about":"The first WayFinder class ship has left the solar system to create the first bridge between two stars.\nHowever, the moment the ship enters normal space around the furthest planet from this foregin star they are met by an alien vessel.\n Under gunned and out classed the Crew is now locked in deck by deck combat with the aliens.",
	"screens":[{"where":"leftscreen","file":"res://packs/waypoints/trappist-1/scenes/2DUI/trappist-1-info.tscn"},{"where":"rightscreen","file":"res://packs/waypoints/trappist-1/scenes/2DUI/trappist-2-info.tscn"}],
	"missions":[{"title":"Arrival","file":"res://packs/waypoints/trappist-1/encounters/Arrival.tscn"},{"title":"Exo-Tera Firma"},{"title":"Pay it Forward"},{"title":"Homeward Bound"}]
}

func get_info():
	return info

