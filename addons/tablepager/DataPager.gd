extends Resource
class_name DataPager

"""
Base Class for DataPager.
Written to work with SQLite plugin that returns data as Array[Dictionary]
See DataPagerSQLite derived class for DB implementation
"""

const COLUMN_KEY_TYPE = "key_type"
const COLUMN_UPDATE_CALLABLE = "update_callable"


# A function on sd3d_db ORM that supports specific paging parameters
# Callable.call(_pageIndex, pagesize[, sortColumn]?) 
var _dataSelectCallable: Callable
var _dataCountCallable: Callable
var _tableConfig: TableConfig
var _columnKeys: Array = []


var _skipSize: int
var _pageSize: int
var _pageMax: int
var _pageIndexCurrent: int = 0
var _sortColumnKey: String = ""
var _sortColumnOrder: TablePager.EnumSortOrder = TablePager.EnumSortOrder.NONE
var _searchText: String = ""



# Parameters for DataPagerResource.new()
func _init(tableConfig: TableConfig):
	_tableConfig = tableConfig
	_dataSelectCallable = tableConfig.dataSelectCallable
	_dataCountCallable = tableConfig.dataCountCallable
	_pageSize = tableConfig.pageSize
	_skipSize = tableConfig.skipSize
	_columnKeys = _tableConfig.GetKeys()
	_sortColumnKey = _tableConfig.GetSortColumn()
	GetDataCount(_searchText)

func GetColumnConfig(columnKey) -> ColumnConfig:
	return _tableConfig.GetColumnConfig(columnKey)
	
func GetDataCount(searchText: String = "") -> int:
	var dataCount: int = _dataCountCallable.call(_searchText)
	resetDataCount(dataCount)
	return dataCount

func GetColumnType(columnKey: String) -> PackedScene:
	var columnConfig: ColumnConfig = _tableConfig.GetColumnConfig(columnKey)
	return columnConfig.cellPackedScene

func GetRowIndex(columnKey: String) -> PackedScene:
	var columnConfig: ColumnConfig = _tableConfig.GetColumnConfig(columnKey)
	return columnConfig.GetRowIndex()

func GetColumnKeys() -> Array:
	return _columnKeys

func GetPageDataCurrent() -> Array:
	GetDataCount(_searchText)
	return _dataSelectCallable.call(_pageSize, _pageIndexCurrent, _sortColumnKey, _sortColumnOrder, _searchText)

func GetPageData(pageNumber: int = 0) -> Array[Dictionary]:
	return _dataSelectCallable.call(pageNumber, _pageSize, _sortColumnKey)

func SetPageIndex(pageIndex: int = 0) -> int:
	if pageIndex >= 0 && pageIndex < _pageMax:
		_pageIndexCurrent = pageIndex
	return _pageIndexCurrent

func SetNextPageIndex() -> int:
	if _pageIndexCurrent + 1 < _pageMax:
		_pageIndexCurrent += 1
	return _pageIndexCurrent

func SetPreviousPageIndex() -> int:
	if _pageIndexCurrent > 0:
		_pageIndexCurrent -= 1
	return _pageIndexCurrent

func SetSkipPreviousPageIndex() -> int:
	if (_pageIndexCurrent - _skipSize) >= 0:
		_pageIndexCurrent -= _skipSize
	else:
		_pageIndexCurrent = 0
	return _pageIndexCurrent

func SetSkipNextPageIndex() -> int:
	if _pageIndexCurrent + _skipSize < _pageMax:
		_pageIndexCurrent += _skipSize
	else:
		_pageIndexCurrent = _pageMax - 1
	return _pageIndexCurrent


func GetPageDataNext() -> Array[Dictionary]:
	var nextPageIndex = _pageIndexCurrent + 1
	var dataResultSet: Array[Dictionary] = _dataSelectCallable.call(_pageSize, nextPageIndex, _sortColumnKey)
	if not dataResultSet.is_empty():
		_pageIndexCurrent = nextPageIndex
	return dataResultSet
		

func GetPageDataPrevious() -> Array[Dictionary]:
	var dataResultSet: Array[Dictionary] = []
	if _pageIndexCurrent > 0:
		var previousPageIndex = _pageIndexCurrent - 1
		dataResultSet = _dataSelectCallable.call(_pageSize, previousPageIndex, _sortColumnKey)
		_pageIndexCurrent = previousPageIndex
	else:
		dataResultSet = _dataSelectCallable.call(_pageSize, _pageIndexCurrent, _sortColumnKey)
	return dataResultSet

func SetSearchText(searchText: String):
	_searchText = searchText
	
func resetDataCount(dataCount: int):
	var currentPageMax = _pageMax
	_pageMax = ceil(dataCount/float(_pageSize))
	if currentPageMax != _pageMax:
		_pageIndexCurrent = 0

func SetSortColumn(columnKey: String) -> String:
	assert(columnKey in _columnKeys, "Unknown columnKey: %s" % columnKey)
	if _sortColumnKey != columnKey:
		_sortColumnKey = columnKey
	return _sortColumnKey

func GetPageDataSorted(columnKey: String, sortOrder: TablePager.EnumSortOrder) -> Array[Dictionary]:
	assert(columnKey in _columnKeys, "Unknown columnKey: %s" % columnKey)
	_sortColumnKey = columnKey
	_sortColumnOrder = sortOrder
	_pageIndexCurrent = 0
	return GetPageDataCurrent()

