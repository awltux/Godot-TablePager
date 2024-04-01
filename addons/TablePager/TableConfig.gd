class_name TableConfig
extends Resource

const DEFAULT_SKIP_SIZE = 5
const DEFAULT_PAGE_SIZE = 10

# Add a ColumnConfig for each column in the table. 
var dataSelectCallable: Callable
var dataCountCallable: Callable
var pageSize: int
var skipSize: int
var _columnConfigs: Dictionary = {}
var _defaultSortColumn: String
# Generic signals that are used to manage sort and width changes.
var widthChangedSignal: Signal
var columnSortSignal: Signal


signal DEFAULT_WIDTH_CHANGED_SIGNAL(newWidth: float)
signal DEFAULT_SORT_SIGNAL(columnName: String, sortOrder: int)

func _init(
			_dataSelectCallable: Callable, 
			_dataCountCallable: Callable, 
			_pageSize: int = DEFAULT_PAGE_SIZE, 
			_skipSize: int = DEFAULT_SKIP_SIZE, 
			_widthChangedSignal: Signal = DEFAULT_WIDTH_CHANGED_SIGNAL, 
			_columnSortSignal: Signal = DEFAULT_SORT_SIGNAL):
	dataSelectCallable = _dataSelectCallable
	dataCountCallable = _dataCountCallable
	pageSize = _pageSize
	skipSize = _skipSize
	widthChangedSignal = _widthChangedSignal
	columnSortSignal = _columnSortSignal

func GetSortColumn() -> String:
	# TODO: if empty return default
	return _defaultSortColumn

func AddColumnConfig(columnConfig: ColumnConfig):
	var keyName = columnConfig.columnName
	assert(not _columnConfigs.has(keyName), "Trying to add a duplicate ColumnConfig for columnKey: %s" % [keyName] )
	# Add the shared signals
	columnConfig.columnSortSignal = columnSortSignal
	columnConfig.widthChangedSignal = widthChangedSignal
	_columnConfigs[keyName] = columnConfig
	
func GetColumnConfig(columnKey: String):
	assert(_columnConfigs.has(columnKey), "columnKey not recognised: %s" % columnKey)
	var columnConfig: ColumnConfig = _columnConfigs[columnKey]
	return columnConfig

func GetKeys() -> Array:
	return _columnConfigs.keys()

