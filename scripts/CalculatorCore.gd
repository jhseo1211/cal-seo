extends RefCounted
class_name CalculatorCore

const ERROR_INPUT := "입력 오류"
const ERROR_UNSUPPORTED := "지원하지 않는 연산"
const ERROR_DIV_ZERO := "0으로 나눌 수 없음"

var _number_regex: RegEx = RegEx.new()

func _init() -> void:
	_number_regex.compile(r"^\s*[-+]?\d*\.?\d+\s*$")

func calculate(op: String, text_a: String, text_b: String) -> Dictionary:
	var operands := _parse_operands(text_a, text_b)
	if not operands.success:
		return {
			success = false,
			display_text = operands.error_text,
			reason = operands.reason
		}

	var a: float = operands.a
	var b: float = operands.b

	var evaluation := _apply_operation(op, a, b)
	if not evaluation.success:
		return evaluation

	var result: float = evaluation.value
	return {
		success = true,
		value = result,
		display_text = _format(result),
		a = a,
		b = b,
		op = op
	}

func _parse_operands(text_a: String, text_b: String) -> Dictionary:
	var parsed_a: Variant = _parse_number(text_a)
	var parsed_b: Variant = _parse_number(text_b)

	if parsed_a == null or parsed_b == null:
		return {
			success = false,
			reason = ERROR_INPUT,
			error_text = ERROR_INPUT
		}

	return {
		success = true,
		a = float(parsed_a),
		b = float(parsed_b)
	}

func _parse_number(raw_text: String) -> Variant:
	var trimmed := raw_text.strip_edges()
	if trimmed == "":
		return 0.0
	if not _number_regex.search(trimmed):
		return null
	return float(trimmed)

func _apply_operation(op: String, a: float, b: float) -> Dictionary:
	match op:
		"+":
			return { success = true, value = a + b }
		"-":
			return { success = true, value = a - b }
		"*":
			return { success = true, value = a * b }
		"/":
			if b == 0.0:
				return {
					success = false,
					reason = ERROR_DIV_ZERO,
					display_text = ERROR_DIV_ZERO
				}
			return { success = true, value = a / b }
		_:
			return {
				success = false,
				reason = ERROR_UNSUPPORTED,
				display_text = ERROR_UNSUPPORTED
			}

func _format(value: float) -> String:
	var text := str(value)
	if text.ends_with(".0"):
		return str(int(value))
	return text
