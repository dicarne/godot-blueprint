extends RefCounted
class_name BPCodeGen

var nodes

var local_vars = {}		# func results
var local_vars_index = 0
var vars = {}			# data node
var lines = []

func gen_by_rungraph(rungraph):
	lines.append("extends RefCounted")
	lines.append("var __VERSION__=" + str(rungraph.version))
	nodes = rungraph.nodes
	var events = rungraph.events
	for n in events:
		var t = gen_statement(events[n])
		if t != null:
			lines.append(t)

	for v in vars:
		lines.append("var V" + v + "=D.new(" + JSON.stringify(vars[v].data) + ")")
	for v in local_vars:
		lines.append("var " + local_vars[v])
	var result = "\n".join(lines)
	#print(result)
	return result

func gen_statement(n: String, tab=0):
	var nd = nodes[n]
	var typeinfo = BPCore.get_node_info(nd.t)
	if typeinfo.type == "data":
		gen_data_call(n, nd.t, nd.d)
		return "V"+n+""
	if typeinfo.type == "func":
		var args = {}
		for k in nd.d:
			var v = nd.d[k]
			if v is String:
				args[k] = "\"" + v + "\""
			else:
				args[k] = v
		for i in nd.i:
			var rnode = BPCore.get_node_info(nodes[nd.i[i][0]].t)
			if _is_exec_node(rnode):
				local_vars[nd.i[i]]
			else:
				args[typeinfo.input_map[i]["v"]] = gen_statement(nd.i[i][0])+".g(\"" + rnode.output_map[nd.i[i][1]]["v"] + "\")"
		var calls = gen_func_call(nd.t, args)
		if _is_exec_node(typeinfo):
			local_vars[n] = "L" + str(local_vars_index)
			local_vars_index += 1
			calls = _tabs(tab) + local_vars[n] + "=" + calls
			lines.append(calls)
			for e in nd.e:
				gen_statement(nd.e[e][0], tab)
			return
		return calls
	if typeinfo.type == "event":
		gen_event(nd.t, n)
		for e in nd.e:
			gen_statement(nd.e[e][0], 1)


func gen_func_call(ftype: String, args: Dictionary={}):
	return "(await C.f(\""+ftype+"\","+object_stringify(args)+"))"

func gen_event(event_name, node_name):
	local_vars[node_name] = "L" + str(local_vars_index)
	local_vars_index += 1
	lines.append("func " + event_name + "(args):")
	lines.append("\t" + local_vars[node_name] + "=" + "args")

func gen_data_call(nodename: String, typename: String, data):
	vars[nodename] = {"type": typename, "data": data}
	return nodename

func _is_exec_node(type: BPFunc):
	return type.output_exec.size() != 0 or type.input_exec.size() != 0

func _tabs(count: int):
	var s = ""
	for c in range(count):
		s += "\t"
	return s

func object_stringify(data: Dictionary):
	var s = "{"
	for k in data:
		s+="\""+k+"\":"
		var v = data[k]
		if v is Dictionary:
			s += object_stringify(v)
		elif v is String:
			s += v
		else:
			s += JSON.stringify(v)
		s += ","
	s += "}"
	return s
