@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("BPCore", "res://addons/blueprint/node/bpcore.gd")
	add_autoload_singleton("C", "res://addons/blueprint/node/bpc.gd")


func _exit_tree():
	remove_autoload_singleton("BPCore")
	remove_autoload_singleton("C")
