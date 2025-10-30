extends Control

@onready var title: Label = $MarginContainer/RootRow/MainColumn/Title
@onready var input_a: LineEdit = $MarginContainer/RootRow/MainColumn/DisplayRow/InputA
@onready var input_b: LineEdit = $MarginContainer/RootRow/MainColumn/DisplayRow/InputB
@onready var btn_7: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn7
@onready var btn_8: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn8
@onready var btn_9: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn9
@onready var btn_4: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn4
@onready var btn_5: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn5
@onready var btn_6: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn6
@onready var btn_1: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn1
@onready var btn_2: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn2
@onready var btn_3: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn3
@onready var btn_0: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/Btn0
@onready var btn_decimal: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/BtnDecimal
@onready var btn_backspace: Button = $MarginContainer/RootRow/MainColumn/KeypadColumn/KeypadGrid/BtnBackspace
@onready var btn_add: Button = $MarginContainer/RootRow/MainColumn/OpsRow/BtnAdd
@onready var btn_sub: Button = $MarginContainer/RootRow/MainColumn/OpsRow/BtnSub
@onready var btn_mul: Button = $MarginContainer/RootRow/MainColumn/OpsRow/BtnMul
@onready var btn_div: Button = $MarginContainer/RootRow/MainColumn/OpsRow/BtnDiv
@onready var btn_equals: Button = $MarginContainer/RootRow/MainColumn/OpsRow/BtnEquals
@onready var btn_clear: Button = $MarginContainer/RootRow/MainColumn/OpsRow/BtnClear
@onready var history_list: VBoxContainer = $MarginContainer/RootRow/HistoryPanel/HistoryMargin/HistoryColumn/HistoryScroll/HistoryList
@onready var btn_history_clear: Button = $MarginContainer/RootRow/HistoryPanel/HistoryMargin/HistoryColumn/BtnHistoryClear

var _core := CalculatorCore.new()
var _history := HistoryStore.new()
var _active_input: LineEdit
var _pending_operator := ""
var _should_reset_input := false

func _ready() -> void:
	btn_add.pressed.connect(_on_op_pressed.bind("+"))
	btn_sub.pressed.connect(_on_op_pressed.bind("-"))
	btn_mul.pressed.connect(_on_op_pressed.bind("*"))
	btn_div.pressed.connect(_on_op_pressed.bind("/"))
	btn_clear.pressed.connect(_on_clear)
	btn_history_clear.pressed.connect(_on_history_clear)
	btn_backspace.pressed.connect(_on_backspace)
	btn_equals.pressed.connect(_on_equals_pressed)

	btn_backspace.text = tr("지우기")

	_connect_digit_button(btn_0, "0")
	_connect_digit_button(btn_1, "1")
	_connect_digit_button(btn_2, "2")
	_connect_digit_button(btn_3, "3")
	_connect_digit_button(btn_4, "4")
	_connect_digit_button(btn_5, "5")
	_connect_digit_button(btn_6, "6")
	_connect_digit_button(btn_7, "7")
	_connect_digit_button(btn_8, "8")
	_connect_digit_button(btn_9, "9")
	_connect_digit_button(btn_decimal, ".")

	_active_input = input_a
	input_a.focus_entered.connect(_on_input_focus.bind(input_a))
	input_b.focus_entered.connect(_on_input_focus.bind(input_b))
	input_a.grab_focus()

	title.text = "미니 계산기"
	input_a.placeholder_text = "숫자A"
	input_b.placeholder_text = "숫자B"

	_refresh_history()

func _on_op_pressed(op: String) -> void:
	var first_text := input_a.text.strip_edges()
	if first_text == "":
		_show_result(tr("숫자를 먼저 입력하세요"))
		return

	_pending_operator = op
	_should_reset_input = false
	if input_b.text != "":
		input_b.text = ""
	_set_active_input(input_b)
	input_b.caret_column = 0
	input_b.grab_focus()
	_show_result("%s %s" % [input_a.text, op])

func _on_clear() -> void:
	input_a.text = ""
	input_b.text = ""
	_pending_operator = ""
	_should_reset_input = false
	_set_active_input(input_a)
	input_a.grab_focus()
	_show_result("미니 계산기")

func _show_result(msg: String) -> void:
	title.text = str(msg)

func _on_equals_pressed() -> void:
	if _pending_operator == "":
		_show_result(tr("연산자를 먼저 선택하세요"))
		return

	var second_text := input_b.text.strip_edges()
	if second_text == "":
		_show_result(tr("두 번째 숫자를 입력하세요"))
		return

	var current_op := _pending_operator
	var outcome := _core.calculate(current_op, input_a.text, input_b.text)
	if not outcome.success:
		_show_result(outcome.display_text)
		return

	_show_result(outcome.display_text)
	_history.record(current_op, outcome.a, outcome.b, outcome.display_text, outcome.value)
	_refresh_history()

	input_a.text = ""
	input_b.text = ""
	_pending_operator = ""
	_should_reset_input = false
	_set_active_input(input_a)
	input_a.grab_focus()
	input_a.caret_column = 0

func get_history() -> Array:
	return _history.get_entries()

func _refresh_history() -> void:
	for child in history_list.get_children():
		history_list.remove_child(child)
		child.queue_free()

	var entries := _history.get_entries()
	if entries.is_empty():
		var placeholder := Label.new()
		placeholder.text = "기록 없음"
		history_list.add_child(placeholder)
		return

	for entry in entries:
		var line := Label.new()
		line.text = _format_history_entry(entry)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		history_list.add_child(line)

func _format_history_entry(entry: Dictionary) -> String:
	var timestamp: float = float(entry.get("timestamp", Time.get_unix_time_from_system()))
	@warning_ignore("narrowing_conversion")
	var time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(timestamp)
	var hour := int(time_dict.get("hour", 0))
	var minute := int(time_dict.get("minute", 0))
	var second := int(time_dict.get("second", 0))
	var time_text := "%02d:%02d:%02d" % [hour, minute, second]
	var a_text := _format_operand(entry.get("a", 0.0))
	var b_text := _format_operand(entry.get("b", 0.0))
	var result_text: String = str(entry.get("display_text", ""))
	return "%s | %s %s %s = %s" % [time_text, a_text, entry.get("op", "?"), b_text, result_text]

func _format_operand(value: Variant) -> String:
	var text := str(value)
	if text.ends_with(".0"):
		return str(int(value))
	return text

func _on_history_clear() -> void:
	_history.clear()
	_refresh_history()

func _connect_digit_button(button: Button, value: String) -> void:
	if button == null:
		return
	button.pressed.connect(func() -> void:
		_on_digit_pressed(value)
	)

func _on_digit_pressed(value: String) -> void:
	var target := _get_active_input()
	if target == null:
		return
	if target == input_a and _should_reset_input:
		target.text = ""
		target.caret_column = 0
		_should_reset_input = false
	target.grab_focus()
	if target.has_selection():
		_delete_selection(target)
	if value == "." and target.text.find(".") != -1:
		return
	target.insert_text_at_caret(value)

func _on_backspace() -> void:
	var target := _get_active_input()
	if target == null:
		return
	if target == input_a and _should_reset_input:
		target.text = ""
		target.caret_column = 0
		_should_reset_input = false
		return
	target.grab_focus()
	if target.has_selection():
		_delete_selection(target)
		return
	var caret := target.caret_column
	if caret <= 0:
		return
	target.select(caret - 1, caret)
	_delete_selection(target)

func _on_input_focus(input: LineEdit) -> void:
	_set_active_input(input)

func _set_active_input(input: LineEdit) -> void:
	if input == null:
		return
	_active_input = input

func _get_active_input() -> LineEdit:
	if _active_input != null and is_instance_valid(_active_input):
		return _active_input
	return input_a

func _delete_selection(target: LineEdit) -> void:
	var from_col := target.get_selection_from_column()
	var to_col := target.get_selection_to_column()
	target.delete_text(from_col, to_col)
	target.deselect()
