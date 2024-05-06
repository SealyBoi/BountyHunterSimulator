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
@onready var armor_img = preload("res://art/items/vgd_iron_armor.png")
@onready var extra_barrel_img = preload("res://art/items/vgd_xtra_barrels_01.png")

# Item 1, 2, and 3
@onready var item1_display = get_node("ItemOptions/Item1")
@onready var item2_display = get_node("ItemOptions/Item2")
@onready var item3_display = get_node("ItemOptions/Item3")

# Max tier per upgrade is 3
var selected_items = [] # Array of five items the player has selected to upgrade
var maxed_tiers = 0 # Max num of tiered items is 5, so if at 3 then we know to return duplicate items

var health_tier = 0
var fr_tier = 0
var speed_tier = 0
var dash_tier = 0
var pen_tier = 0
var dam_tier = 0
var armor_tier = 0
var barrel_tier = 0

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
	selected_items.append(item.mod)
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
		"armor":
			armor_tier += 1
		"barrel":
			barrel_tier += 1

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
		"armor":
			tier = armor_tier
		"barrel":
			tier = barrel_tier
	if tier >= 3:
		return true
	else:
		return false

func can_item_be_selected(item, item_num):
	if tier_is_max(item.mod):
		return select_random_item(item_num)
	
	if maxed_tiers >= 3: # Reached max tiers, so go ahead and return that item
		return item
	
	if item1 == null: # If item1 is null, then return item
		return item
	
	if item2 == null and item.mod != item1.mod: # If item2 is null, return if it does not equal item1
		return item
	
	if item3 == null and item.mod != item1.mod and item.mod != item2.mod: # If item2 is null, return if it does not equal item1 or item2
		return item
	
	match item_num: # Switch between which item slot is being filled
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
	match randi_range(1, 7):
		1:
			return can_item_be_selected(Item.new("Can O' Beans", can_o_beans_img, "Increase health maximum", "health", 3), item_num)
		2:
			return can_item_be_selected(Item.new("Quick Trigger", quick_trigger_img, "Increase weapon fire rate", "fire_rate", 0.1), item_num)
		3:
			return can_item_be_selected(Item.new("Feather Boots", feather_boots_img, "Increase movement speed", "speed", 50), item_num)
		4:
			return can_item_be_selected(Item.new("Quick Dash", quick_dash_img, "Decrease dash cooldown time", "dash_cooldown", 0.2), item_num)
		5:
			return can_item_be_selected(Item.new("Piercing Bullets", piercing_bullets_img, "Increase bullet penetration", "pierce", 1), item_num)
		6:
			return can_item_be_selected(Item.new("FMJ Rounds", fmj_rounds_img, "Increase bullet damage", "damage", 1), item_num)
		7:
			return can_item_be_selected(Item.new("Armor Vest", armor_img, "Decreases damage dealt by enemies", "armor", .1), item_num)
		8:
			return can_item_be_selected(Item.new("Extra Barrel", extra_barrel_img, "Increases number of bullets fired", "barrel", 1), item_num)
