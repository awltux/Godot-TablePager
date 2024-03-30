extends CellBase
class_name CellCheckButtonUpdate

var _signalForUpdated: Signal
# Don't trigger _on_check_button_toggled whild initilialising the table.
var initialised = false

@onready var check_button: CheckButton = %CheckButton

func Initialise(rowData: Dictionary, columnConfig: ColumnConfig):
	SetBaseProperties(rowData, columnConfig)
	# OPTIONAL SIGNAL
	if columnConfig.HasCellConfig(ColumnConfig.CELL_UPDATED_SIGNAL):
		_signalForUpdated = columnConfig.GetCellConfig(ColumnConfig.CELL_UPDATED_SIGNAL)

func _ready():
	_update_check_button()
	initialised = true

func _update_check_button():
	var checkValue := bool(_columnValue)
	if check_button:
		check_button.button_pressed = checkValue

func _on_check_button_toggled(toggled_on):
	if initialised && _signalForUpdated:
		_signalForUpdated.emit(_columnName, _rowIndex, toggled_on)
