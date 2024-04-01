extends CellBase
class_name CellLabel

@onready var label = %Label

# Could be an integer or a String - we dont care
var _signalForSelected: Signal

func Initialise(rowData: Dictionary, columnConfig: ColumnConfig):
	SetBaseProperties(rowData, columnConfig)
	# OPTIONAL SIGNAL
	if columnConfig.HasCellConfig(ColumnConfig.CELL_SELECTED_SIGNAL):
		_signalForSelected = columnConfig.GetCellConfig(ColumnConfig.CELL_SELECTED_SIGNAL)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = str(_columnValue)

func _on_button_pressed():
	# The cell was pressed, someone may want to know
	if _signalForSelected:
		_signalForSelected.emit(_columnName, _rowIndex)
