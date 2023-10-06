extends GraphNode
class_name BPNode

var data = {}
var nodetypename: String
var slots_setter = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reload_data():
	for k in data:
		if k in slots_setter:
			slots_setter[k].call(data[k])

func reg_slot_setter(value_field: String, setter: Callable):
	slots_setter[value_field] = setter

func handle_value_change(newvalue, value_field: String):
	data[value_field] = newvalue

