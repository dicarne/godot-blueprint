extends RefCounted
class_name BPFunc

func _init():
	pass

var type = "event"
var id = "_example"
var title = "Example Func Node"
var slots = [
	{
		"right": {
			"type": "EXEC"
		}
	},
	{
		"right": {
			"type":"String",
			"text": "Output Sample"
		},
	}
]

var listen_event_id = "core@onready"

func onevent():
	print("debug: trigger " + listen_event_id)

func exec(args):
	pass

var input_map
var output_map
var input_exec
var output_exec

func _rebuild_slot_map():
	input_map = {}
	output_map = {}
	input_exec = {}
	output_exec = {}
	var port = 0
	for it in slots:
		var l = it.get("left")
		if l != null:
			if l.type != "none":
				if l.type == "EXEC":
					input_exec[str(port)] = {
						"v": l.get("bind", "EXEC")
					}
				elif "bind" in l:
					input_map[str(port)] = {
						"v": l["bind"],
						"d": l.get("default")
					}
				port += 1
	port = 0
	for it in slots:
		var l = it.get("right")
		if l != null:
			if l.type != "none":
				if l.type == "EXEC":
					output_exec[str(port)] = {
						"v": l.get("bind", "EXEC")
					}
				elif "bind" in l:
					output_map[str(port)] = {
						"v": l["bind"],
						"d": l.get("default")
					}
				port += 1


