extends RefCounted
class_name D

var _v = {}

func g(key=null):
	if key != null:
		return {"s": self, "v": _v.get(key), "k": key}
	return _v

func s(key, nv):
	_v[key] = nv

func _init(initdata={}):
	_v = initdata
