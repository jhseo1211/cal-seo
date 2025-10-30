extends RefCounted
class_name HistoryStore

var capacity: int = 20
var _entries: Array = []

func record(op: String, a: float, b: float, display_text: String, value: float) -> void:
	var entry := {
		"op": op,
		"a": a,
		"b": b,
		"display_text": display_text,
		"value": value,
		"timestamp": Time.get_unix_time_from_system()
	}

	_entries.push_front(entry)
	if _entries.size() > capacity:
		_entries.resize(capacity)

func clear() -> void:
	_entries.clear()

func get_entries() -> Array:
	return _entries.duplicate(true)
