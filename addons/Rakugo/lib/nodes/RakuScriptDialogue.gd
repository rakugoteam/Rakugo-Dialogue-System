@icon("res://addons/Rakugo/icons/Script.svg")
## Simple node to load and run Raku Script
class_name RakuScriptDialogue
extends Node

## Raku Script (*.rk) to load and run
@export_file("*.rk") var raku_script : String

## Label to start raku_script when using start_dialogue()
@export var starting_label_name := ""

## If true calls start_dialogue() when scene is ready
@export var auto_start := false

func _ready():
	if auto_start:
		start_dialogue()

## Starts raku_script from start_dialogue_from_label 
func start_dialogue():
	start_dialogue_from_label(starting_label_name)

## Starts raku_script from given label
func start_dialogue_from_label(label_name : String):
	Rakugo.parse_and_execute_script(raku_script, label_name)
