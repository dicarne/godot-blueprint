extends Node

func f(fun: String, args={}):
	return await BPCore.get_node_info(fun).exec(args)
