extends GraphEdit
class_name BPGraph

func _init():
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	connection_to_empty.connect(_on_connection_to_empty)
	connection_from_empty.connect(_on_connection_from_empty)
	BPCore.inject_valid_type_to_graph(self)

var index = 0

func test():
	add_node("event_onready", size / 2)
	add_node("func_print", size / 2)
	add_node("data_string", size / 2)
	add_node("func_string_uppercase", size / 2)

func _ready():
	pass # Replace with function body.
	add_valid_connection_type(1, 0)

func _on_connection_request(from_node, from_port, to_node, to_port):
	var old = get_left_connections(to_node, to_port)
	if len(old) != 0:
		return
	print(from_node, from_port, to_node, to_port)
	connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node, from_port, to_node, to_port):
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_connection_to_empty(from_node, from_port, release_position):
	print("_on_connection_to_empty")
	print("新建符合节点类型的菜单")

func _on_connection_from_empty(to_node, to_port, release_position):
	var old = get_left_connections(to_node, to_port)
	if len(old) != 0:
		for it in old:
			disconnect_node(it.from_node, it.from_port, it.to_node, it.to_port)

func get_left_connections(from_node, from_port):
	var ns = get_connection_list()
	var res = []
	for it in ns:
		if it.to_node == from_node and it.to_port == from_port:
			res.append(it)
	return res

func _is_node_hover_valid(from, from_port, to, to_port):
	return from != to

func get_input_type(node, port):
	var n = get_node(node) as GraphNode
	var port_type = n.get_input_port_type(port)
	
func get_output_type(node, port):
	var n = get_node(node) as GraphNode
	var port_type = n.get_out_port_type(port)

func add_node(nodename: String, pos: Vector2 = Vector2.ZERO, data={}):
	var n = BPCore.get_node_info(nodename) as BPFunc
	assert(n != null, "BPFunc not found: " + nodename)
	var ins = BPNode.new()
	ins.nodetypename = nodename
	var slots = n.slots
	ins.title = n.title
	for i in range(len(slots)):
		var s = slots[i]
		var c = HBoxContainer.new()
		var l = s.get("left")
		if l != null:
			var lb = _build_slot(i, l, ins)
			if lb != null:
				c.add_child(lb)
				lb.size_flags_horizontal = Control.SIZE_EXPAND
		var r = s.get("right")
		if r != null:
			var lr = _build_slot(i, r, ins)
			if lr != null:
				c.add_child(lr)
		if c.get_child_count() == 0:
			var lb = Label.new()
			lb.text = " "
			c.add_child(lb)
		ins.add_child(c)

	for i in range(len(slots)):
		var s = slots[i]
		var l = s.get("left")
		if l != null:
			_init_slot(i, ins, l, "left")
		var r = s.get("right")
		if r != null:
			_init_slot(i, ins, r, "right")
	add_child(ins)
	ins.name = str(index)
	index += 1
	ins.position_offset = pos
	for k in data:
		ins.data[k] = data[k]
	ins.reload_data()
	return ins

func _build_slot(index: int, slotdata, node: BPNode):
	if "text" in slotdata:
		var lb = Label.new()
		lb.text = slotdata.text
		return lb
	if "textinput" in slotdata:
		var ct = LineEdit.new()
		ct.text = slotdata["textinput"]
		ct.text_changed.connect(node.handle_value_change.bind(slotdata.bind))
		node.reg_slot_setter(slotdata.bind, func(nv): ct.text = nv)
		return ct

func _init_slot(index: int, node: BPNode, slotdata, pos):
	var type = slotdata.get("type")
	if type != null:
		var typeinfo = BPCore.get_type_by_name(type)
		if pos == "left":
			node.set_slot_enabled_left(index, true)
			node.set_slot_type_left(index, typeinfo.id)
			node.set_slot_color_left(index, typeinfo.color)
		else:
			node.set_slot_enabled_right(index, true)
			node.set_slot_type_right(index, typeinfo.id)
			node.set_slot_color_right(index, typeinfo.color)

func generate_rawgraph():
	var nodes = {}
	var conns = get_connection_list()
	var simple_conns = []
	for c in conns:
		simple_conns.append([c.from_node, str(c.from_port), c.to_node, str(c.to_port)])
	var g = {
		"version": 1,
		"nodes": nodes,
		"connections": simple_conns,
		"index": index,
	}
	for n in get_children():
		if n is BPNode:
			nodes[n.name] = {
				"type": n.nodetypename,
				#"name": n.name,
				"data": n.data,
				"pos": [int(n.position_offset.x), int(n.position_offset.y)]
			}
	return g

func load_rawgraph(rawgraph):
	index = rawgraph.index
	var nodes = rawgraph.nodes
	for ni in nodes:
		var n = nodes[ni]
		var ins = add_node(n.type, Vector2(n.pos[0], n.pos[1]), n.data)
		ins.name = ni
	for c in rawgraph.connections:
		connect_node(c[0], int(c[1]), c[2], int(c[3]))
