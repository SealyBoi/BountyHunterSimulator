extends Control

@onready var main = $Main
@onready var play = $Main/VBoxContainer/HBoxContainer/Play
@onready var tutorial = $Main/VBoxContainer/HBoxContainer/Tutorial
@onready var quit = $Main/VBoxContainer/Quit

@onready var tutorial_menu = $Tutorial
@onready var back = $Tutorial/Back

@onready var audio = $AudioStreamPlayer2D

func _ready():
	main.visible = true
	play.disabled = false
	tutorial.disabled = false
	quit.disabled = false
	tutorial_menu.visible = false
	back.disabled = true
	play.grab_focus()

func flip_menus():
	main.visible = not main.visible
	play.disabled = not play.disabled
	tutorial.disabled = not tutorial.disabled
	quit.disabled = not quit.disabled
	tutorial_menu.visible = not tutorial_menu.visible
	back.disabled = not back.disabled


func _on_play_pressed():
	audio.play()
	get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")


func _on_tutorial_pressed():
	audio.play()
	flip_menus()
	back.grab_focus()


func _on_back_pressed():
	audio.play()
	flip_menus()
	play.grab_focus()


func _on_quit_pressed():
	audio.play()
	get_tree().quit()
