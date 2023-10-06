extends BPFunc


func _init():
	super()
	id = "func_string_add"
	title = "String add"
	type = "func"
	slots = [
		{
			"left": {
				"type": "String",
				"bind": "value1",
				"text": "+"
			},
			"right": {
				"type": "String",
				"bind": "value",
			}
		},{
			"left": {
				"type": "String",
				"bind": "value2",
			},
		}
	]

func exec(args):
	return D.new({
		"value": args.get("value1", {"v": ""}).v + args.get("value2", {"v": ""}).v
	})
