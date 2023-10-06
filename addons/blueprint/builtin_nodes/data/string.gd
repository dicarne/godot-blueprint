extends BPFunc

func _init():
	super()
	type = "data"
	id = "data_string"
	title = "String"
	slots = [
		{
			"right": {
				"type": "String",
				"textinput": "",
				"bind": "value"
			}
		}
	]
