class_name ColumnConfig
extends Resource

"""
Developer creates and Array of these Resources to 
declares how each Table Column should be created. 
"""

##############################################################################
## THESE ARE KEYS FOR THE cellConfig Dictionary
##############################################################################

# Cell must emit this signal when clicked e.g. a CellLabel
# It passes:
#    a row_index
#    a column name
const CELL_SELECTED_SIGNAL: String = "cell_selected_signal"
# Signal emitted when a column-row has been changed e.g. slider or CheckButton
# Cell must emit this signal passing: 
#    a row_index - must match an existing row
#    a column_name - Must match an existing column
#    a cell_value
const CELL_UPDATED_SIGNAL: String = "cell_updated_signal"

# All Cells must listen for this signal and adjust their width when received
# It is emitted from the Header Cell
# It passes:
#    a row uuid
#    a column name
const COLUMN_WIDTH_CHANGED_SIGNAL: String = "column_width_changed_signal"

# This is called when the header button is clicked
# NOTE: Only relevant to Header Cell
# It passes: 
#     the column name to sort on
#     enum indicating ascending, decending or none(database order)
const COLUMN_SORT_SIGNAL: String = "column_sort_signal"

# Bool indicates if column should be fixed width or expanding into available space
# Some columns benifit from always being a certain size.
const COLUMN_WIDTH_FIXED: String = "column_width_fixed"

# Column width
# Some cell components cannot go any smaller than a certain size. 
# This tells the header to not shrink any further than the column cell
const COLUMN_WIDTH_PX: String = "column_width_px"



# Used a default, but can be overridden.
var headerPackedScene: PackedScene

# Reference to a PackedScene that will be used to creat a cell for this column
# TablePager has a few examples, but any scene can be passed
# Script must implement some variables and methods:
# NOTE: Row creation fails if ColumnConfig.signalFor* not null and 
#       the property is missing on the ColumnConfig.cellPackedScene.
# var uuid: String
# var signalForSort: Signal
#     NOTE: Only really relevant to Header Cell
# var signalForUpdated: Signal
# var signalForSelected: Signal
# NOTE: Override this default if required 
var cellPackedScene: PackedScene

# Used by the DataPager to sort and update columns
var columnName: String

# The data key name that uniquely identifies a row of the data for this column
# NOTE: Each column could come from a diffferent table (Think of a DB TABLE VIEW), so make INDEX_NAME column specific
var rowIndexName: String

var widthChangedSignal: Signal

var columnSortSignal: Signal

# Optional: Each cell component defines a set of valid entries
# Common keys are defined as constants in this file.
# CellType specific keys will be defined in the Cell script itself.
var cellConfig: Dictionary = {}

func _init(	_headerPackedScene: PackedScene, 
			_cellPackedScene: PackedScene, 
			_columnName: String, 
			_rowIndexName: String):

	headerPackedScene = _headerPackedScene 
	cellPackedScene = _cellPackedScene
	columnName = _columnName 
	rowIndexName = _rowIndexName
	
func HasCellConfig(configKey: String) -> bool:
	return cellConfig.has(configKey)
	
func GetCellConfig(configKey: String) -> Variant:
	assert(HasCellConfig(configKey), "Missing entry for TableConfig._columnConfigs[\"%s\"].cellConfig[\"%s\"]" % [columnName, configKey])
	return cellConfig[configKey]

func AddCellConfig(configKey: String, configValue: Variant):
	assert(not HasCellConfig(configKey), "Duplicate entry for TableConfig._columnConfigs[\"%s\"].cellConfig[\"%s\"]" % [columnName, configKey])
	cellConfig[configKey] = configValue
