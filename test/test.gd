extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists("user://test.gd"):
		graph = BPGraph.new()
		%P.add_child(graph)
		var f = FileAccess.open("user://test.gd", FileAccess.READ)
		savedata = JSON.parse_string(f.get_as_text())
		graph.load_rawgraph(savedata)
	else:
		graph = BPGraph.new()
		%P.add_child(graph)
		await get_tree().process_frame
		graph.test()
	
	for n in BPCore.get_all_node_names():
		%Nodes.add_item(n)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@onready var graph

var savedata = null
func _on_save_button_pressed():
	pass # Replace with function body.
	savedata = graph.generate_rawgraph()
	var f = FileAccess.open("user://test.gd", FileAccess.WRITE)
	f.store_string(JSON.stringify(savedata))
	print(savedata)


func _on_reload_button_pressed():
	if savedata == null:
		print("not saved!")
		return
	graph.queue_free()
	graph = BPGraph.new()
	%P.add_child(graph)
	graph.load_rawgraph(JSON.parse_string(JSON.stringify(savedata)))


func _on_run_button_pressed():
	var rawg = JSON.parse_string(JSON.stringify(graph.generate_rawgraph()))
	var rung = BPCore.generate_rungraph(rawg)
	var newscript = BPCodeGen.new().gen_by_rungraph(rung)
	
	var gds = GDScript.new()
	gds.source_code = newscript
	print("======")
	print(newscript)
	print("======")
	gds.reload()
	var o = RefCounted.new()
	o.set_script(gds)
	o.event_onready({})


func _on_nodes_item_activated(index):
	var n = %Nodes.get_item_text(index)
	graph.add_node(n, graph.size / 2)
