extends BPFunc


func _init():
	super()
	id = "func_string_setter"
	title = "String setter"
	type = "func"
	slots = [
		{
			"left": {
				"type": "String",
				"bind": "source",
			},
			"right": {
				"type": "String",
				"bind": "newvalue",
			},
		},{
			"left": {
				"type": "String",
				"bind": "target",
			}
		}
	]

func exec(args):
	var newv = args.get("target", {"v": ""}).v
	if "source" in args:
		var o = args["source"]
		o.s.s(o.k, newv)
		return D.new({
			"newvalue": newv
		})
	return D.new({
			"newvalue": ""
	})
