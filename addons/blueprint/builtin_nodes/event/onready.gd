extends BPFunc

func _init():
	super()
	title = "On Ready"
	id = "event_onready"
	listen_event_id = "core@onready"
	slots = [
	{
		"right": {
			"type": "EXEC"
		}
	}
]
