extends BPFunc


func _init():
	super()
	id = "func_string_uppercase"
	title = "Uppercase"
	type = "func"
	slots = [
		{
			"left": {
				"type": "String",
				"bind": "value",
			},
			"right": {
				"type": "String",
				"bind": "value",
			}
		},
	]

func exec(args):
	return D.new({
		"value": args.get("value", {"v": ""}).v.to_upper()
	})
