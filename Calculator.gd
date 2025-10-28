extends Control

@onready var title: Label        = $MarginContainer/VBoxContainer/Title
@onready var input_a: LineEdit   = $MarginContainer/VBoxContainer/DisplayRow/InputA
@onready var input_b: LineEdit   = $MarginContainer/VBoxContainer/DisplayRow/InputB

@onready var btn_add: Button     = $MarginContainer/VBoxContainer/OpsRow/BtnAdd
@onready var btn_sub: Button     = $MarginContainer/VBoxContainer/OpsRow/BtnSub
@onready var btn_mul: Button     = $MarginContainer/VBoxContainer/OpsRow/BtnMul
@onready var btn_div: Button     = $MarginContainer/VBoxContainer/OpsRow/BtnDiv
@onready var btn_clear: Button   = $MarginContainer/VBoxContainer/OpsRow/BtnClear

func _ready() -> void:
	btn_add.pressed.connect(_on_op_pressed.bind("+"))
	btn_sub.pressed.connect(_on_op_pressed.bind("-"))
	btn_mul.pressed.connect(_on_op_pressed.bind("*"))
	btn_div.pressed.connect(_on_op_pressed.bind("/"))
	btn_clear.pressed.connect(_on_clear)

	title.text = "미니 계산기"
	input_a.placeholder_text = "숫자A"
	input_b.placeholder_text = "숫자B"

func _on_op_pressed(op: String) -> void:
	var a_val: Variant = _parse_number(input_a.text)
	var b_val: Variant = _parse_number(input_b.text)

	if a_val == null or b_val == null:
		_show_result("입력 오류")
		return

	var a: float = float(a_val)
	var b: float = float(b_val)

	var result: float = 0.0
	match op:
		"+":
			result = a + b
		"-":
			result = a - b
		"*":
			result = a * b
		"/":
			if b == 0.0:
				_show_result("0으로 나눌 수 없음")
				return
			result = a / b
		_:
			_show_result("지원하지 않는 연산")
			return

	_show_result(_format(result))

func _on_clear() -> void:
	input_a.text = ""
	input_b.text = ""
	_show_result("미니 계산기")

func _show_result(msg: String) -> void:
	title.text = str(msg)

# 숫자면 float, 아니면 null 반환
func _parse_number(s: String) -> Variant:
	var t: String = s.strip_edges()
	if t == "":
		return 0.0
	var re := RegEx.new()
	re.compile(r"^\s*[-+]?\d*\.?\d+\s*$")
	if not re.search(t):
		return null
	return float(t)

func _format(v: float) -> String:
	var s := str(v)
	if s.ends_with(".0"):
		return str(int(v))
	return s
