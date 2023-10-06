extends Node

func _init():
	_add_default_types()


######## TYPE ########
var _id_type = {}
var _name_type = {}
var _type_index = 0

func add_type(typename: String, color: Color):
	if typename in _id_type:
		printerr("type already registered: ", typename)
		return
	var t = {
		"name": typename,
		"id": _type_index,
		"color": color,
	}
	_id_type[_type_index] = t
	_name_type[typename] = t
	_type_index += 1

func get_type_id(typename: String) -> int:
	return _name_type[typename].id

func get_type_name(id: int) -> String:
	return _id_type[id].name

func get_type_by_id(id: int):
	return _id_type[id]

func get_type_by_name(typename: String):
	return _name_type[typename]

func get_all_types():
	var names = []
	return _name_type.keys()

func _add_default_types():
	add_type("EXEC", Color.WHITE)
	add_type("int", Color.SKY_BLUE)
	add_type("String", Color.PURPLE)
	add_type("float", Color.PURPLE)
	add_type("Vector2", Color.PURPLE)
	add_type("Vector3", Color.PURPLE)
	add_type("Vector4", Color.PURPLE)
	add_type_convert("int", "String", func(a: int): JSON.stringify(a))
	add_type_convert("int", "float", func(a: int): float(a))
	add_type_convert("Vector4", "Vector3", func(a: Vector4): Vector3(a.x, a.y, a.z))
	add_type_convert("Vector3", "Vector2", func(a: Vector3): Vector2(a.x, a.y))
	
	register_node("res://addons/blueprint/builtin_nodes/event/onready.gd")
	register_node("res://addons/blueprint/builtin_nodes/func/print.gd")
	register_node("res://addons/blueprint/builtin_nodes/data/string.gd")
	register_node("res://addons/blueprint/builtin_nodes/func/string/uppercase.gd")
	register_node("res://addons/blueprint/builtin_nodes/func/string/add.gd")
	register_node("res://addons/blueprint/builtin_nodes/func/string/setter.gd")

var _type_convert = {}
var _valid_connection = {}
func add_type_convert(from_name: String, to_name: String, cvt: Callable):
	var id1 = get_type_id(from_name)
	var id2 = get_type_id(to_name)
	_valid_connection[id1] = id2
	_type_convert[from_name + "->" + to_name] = cvt

func inject_valid_type_to_graph(g: BPGraph):
	for k in _valid_connection:
		g.add_valid_connection_type(k, _valid_connection[k])

func get_type_convert_by_id(from_typeid: int, to_typeid: int):
	return _type_convert.get(get_type_name(from_typeid) + "->" + get_type_name(to_typeid))

func get_type_convert_by_name(from_type: String, to_type: String):
	return _type_convert.get(from_type + "->" + to_type)

######## NODE ########
var _nodes = {}

func register_node(nodepath):
	var n = load(nodepath).new() as BPFunc
	assert(n != null, "All scripts need to be BPFunc.")
	_nodes[n.id] = n
	n._rebuild_slot_map()

func get_node_info(nodeid: String) -> BPFunc:
	return _nodes.get(nodeid) as BPFunc

func generate_rungraph(rawgraph: Dictionary):
	var rtnodes = {}
	var events = {}
	var nodes = rawgraph.nodes
	for iname in nodes:
		var it = nodes[iname]
		it["input"] = {}
		it["output"] = {}
	for c in rawgraph.connections:
		nodes[c[0]].output[c[1]] = [c[2], c[3]]
		nodes[c[2]].input[c[3]] = [c[0], c[1]]
	for iname in nodes:
		var it = nodes[iname]
		var typeinfo = get_node_info(it.type)
		if typeinfo.type == "event":
			events[it.type] = iname
		#var rt = D.new(typeinfo, it.data)
		var input_data = {}
		for ip in it.input:
			if not typeinfo.input_exec.has(ip):
				input_data[ip] = it.input[ip]
		var exec_data = {}
		for ip in it.output:
			if ip in typeinfo.output_exec:
				exec_data[ip] = it.output[ip]
		rtnodes[iname] = {
			"t": it.type,
			"i": input_data,
			"e": exec_data,
			"d": it.data,
		}

	var r = {
		"version": rawgraph.version,
		"events": events,
		"nodes": rtnodes,
	}
	return r

func get_all_node_names():
	return _nodes.keys()

func f(fun: String, args={}):
	return await get_node_info(fun).exec(args)
