class_name Item extends Node2D

# Properties
var title: String
var image: Texture2D
var desc: String
var mod: String
var value: float

func _init(new_title: String, new_image: Texture2D, new_desc: String, new_mod: String, new_value: float):
	title = new_title
	image = new_image
	desc = new_desc
	mod = new_mod
	value = new_value
