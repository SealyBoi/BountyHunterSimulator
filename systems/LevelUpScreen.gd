extends Control

# Title, Desc, Mod, Value
@onready var Item = load("res://items/basic_item.gd")
@onready var player = get_tree().get_root().get_node("TestArea/Player")

# Item images
@onready var can_o_beans_img = preload("res://art/items/vgd_can_o_beans.png")
@onready var quick_trigger_img = preload("res://art/items/vgd_lightning_bolt.png")
@onready var feather_boots_img = preload("res://art/items/vgd_winged_shoes.png")
@onready var quick_dash_img = preload("res://art/items/vgd_stop_watch.png")
@onready var piercing_bullets_img = preload("res://art/items/vgd_spiked_bullet.png")
@onready var fmj_rounds_img = preload("res://art/items/vgd_hot_bullet.png")

# Item 1, 2, and 3
@onready var item1_display = get_node("ItemOptions/Item1")
@onready var item2_display = get_node("ItemOptions/Item2")
@onready var item3_display = get_node("ItemOptions/Item3")

# Max tier per upgrade is 3
var maxed_tiers = 0 # Max is 6. If at 4, then we know to duplicate items
var health_tier = 0
var fr_tier = 0
var speed_tier = 0
var dash_tier = 0
var pen_tier = 0
var dam_tier = 0

var item1: Item
var item2: Item
var item3: Item

func _ready():
	select_new_items()

func unpause():
	visible = false
	get_tree().paused = false


func _on_item1_button_pressed():
	continue_game(item1)


func _on_item2_button_pressed():
	continue_game(item2)


func _on_item3_button_pressed():
	continue_game(item3)

func continue_game(item: Item):
	purchase_item(item)
	increase_tier(item)
	unpause()
	select_new_items()

func purchase_item(item: Item):
	player.modify_stat(item.mod, item.value)

func increase_tier(item: Item):
	match item.mod:
		"health":
			health_tier += 1
		"fire_rate":
			fr_tier += 1
		"speed":
			speed_tier += 1
		"dash_cooldown":
			dash_tier += 1
		"pierce":
			pen_tier += 1
		"damage":
			dam_tier += 1

# Takes in an item and it's parent and modifies the appropriate text, icons, etc.
func modify_item(item: Item, display: VBoxContainer):
	display.get_node("ItemName").text = item.title
	display.get_node("ItemButton").icon = item.image
	display.get_node("ItemDesc").text = item.desc

func select_new_items():
	item1 = select_random_item(1)
	item2 = select_random_item(2)
	item3 = select_random_item(3)
	
	# Modify buttons to represent items correctly
	modify_item(item1, item1_display)
	modify_item(item2, item2_display)
	modify_item(item3, item3_display)

func tier_is_max(mod: String):
	var tier: int
	match mod:
		"health":
			tier = health_tier
		"fire_rate":
			tier = fr_tier
		"speed":
			tier = speed_tier
		"dash_cooldown":
			tier = dash_tier
		"pierce":
			tier = pen_tier
		"damage":
			tier = dam_tier
	if tier >= 3:
		return true
	else:
		return false

func can_item_be_selected(item, item_num):
	if maxed_tiers >= 4 or item1 == null:
		return item
	
	if item2 == null and item != item1:
		return item
	
	if tier_is_max(item.mod):
		return select_random_item(item_num)
	
	match item_num:
		1:
			if item.mod != item2.mod and item.mod != item3.mod:
				return item
			else:
				return select_random_item(item_num)
		2:
			if item.mod != item1.mod and item.mod != item3.mod:
				return item
			else:
				return select_random_item(item_num)
		3:
			if item.mod != item1.mod and item.mod != item2.mod:
				return item
			else:
				return select_random_item(item_num)

func select_random_item(item_num):
	match randi_range(0, 5):
		0:
			return can_item_be_selected(Item.new("Can O' Beans", can_o_beans_img, "Increase health maximum", "health", 3), item_num)
		1:
			return can_item_be_selected(Item.new("Quick Trigger", quick_trigger_img, "Increase weapon fire rate", "fire_rate", 0.1), item_num)
		2:
			return can_item_be_selected(Item.new("Feather Boots", feather_boots_img, "Increase movement speed", "speed", 50), item_num)
		3:
			return can_item_be_selected(Item.new("Quick Dash", quick_dash_img, "Decrease dash cooldown time", "dash_cooldown", 0.2), item_num)
		4:
			return can_item_be_selected(Item.new("Piercing Bullets", piercing_bullets_img, "Increase bullet penetration", "pierce", 1), item_num)
		5:
			return can_item_be_selected(Item.new("FMJ Rounds", fmj_rounds_img, "Increase bullet damage", "damage", 1), item_num)
