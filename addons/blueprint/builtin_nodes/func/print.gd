extends BPFunc

func _init():
	super()
	id = "func_print"
	title = "Print"
	type = "func"
	slots = [
		{
			"left": {
				"type": "EXEC"
			},
			"right": {
				"type": "EXEC"
			}
		},
		{
			"left": {
				"type": "String",
				"text": "消息",
				"bind": "value",
				"default": "Hello BP!"
			}
		}
	]

func exec(args):
	print(args.get("value", {"v":""}).v)
