extends PanelContainer
class_name CellBase

const DEFAULT_WIDTH_PX: int = -1
const DEFAULT_FIXED_WIDTH: bool = false

var _rowIndexName: String
var _rowIndex: Variant
var _columnName: String
var _columnValue: Variant
var _widthChangedSignal: Signal

var _customMinimumSize: int = DEFAULT_WIDTH_PX
var _expandHorizontal: bool = DEFAULT_FIXED_WIDTH

func _enter_tree():
	_widthChangedSignal.connect(_handleWidthChanged)
	
func _exit_tree():
	_widthChangedSignal.disconnect(_handleWidthChanged)
	
func _handleWidthChanged(columnName: String, customMinimumSize: float):
	if columnName == _columnName:

		_customMinimumSize = customMinimumSize
		custom_minimum_size = Vector2(customMinimumSize, 0)

		if _expandHorizontal:
			size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			size_flags_horizontal = Control.SIZE_FILL

func SetBaseProperties(rowData: Dictionary, columnConfig: ColumnConfig):
	_columnName = columnConfig.columnName
	_rowIndexName = columnConfig.rowIndexName
	_widthChangedSignal = columnConfig.widthChangedSignal

	# Header passes empty rowData
	if not rowData.is_empty():
		assert(rowData.has(_columnName), "rowData doesnt have a key: %s" % [_columnName])
		_columnValue = rowData[_columnName]

		assert(rowData.has(_rowIndexName), "rowData doesnt have a key: %s" % [_rowIndexName])
		_rowIndex = rowData[_rowIndexName]

	if columnConfig.HasCellConfig(ColumnConfig.COLUMN_WIDTH_PX):
		_customMinimumSize = columnConfig.GetCellConfig(ColumnConfig.COLUMN_WIDTH_PX)
		custom_minimum_size = Vector2(_customMinimumSize, 0)
	
	if columnConfig.HasCellConfig(ColumnConfig.COLUMN_WIDTH_FIXED):
		_expandHorizontal = not columnConfig.GetCellConfig(ColumnConfig.COLUMN_WIDTH_FIXED)
		if _expandHorizontal:
			size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			size_flags_horizontal = Control.SIZE_FILL
	
