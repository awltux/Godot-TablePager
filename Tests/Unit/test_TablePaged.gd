extends GutTest

signal columnWidthChangedSignal(newWidth: float)

var danceClassTitle = "test"
const TABLE_PAGED = preload("res://addons/TablePager/Components/TablePager/TablePager.tscn")
const HEADER_COUNT: int = 1
const HEADER_INDEX: int = 0

var dataArray: Array[Dictionary] = []
const columnKeys: Array[String] = ["key_one", "keyTwo", "key_three"]
const headerNames: Array[String] = ["Key One", "Key Two", "Key Three"]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var lastSortValue: bool
var lastSortKey: String

func before_each():
	pass

func after_each():
	pass

func test_TablePager_Headers():
	var pageSize = 5
	var dataSize = 100
	createIntegerData(dataSize)
	
	var tableConfig:TableConfig = autofree(TableConfig.new(SelectPage, RowCount, pageSize))
	# Pick and arbitrary columnKey to be the primaryKey
	var rowIndexName = columnKeys[0]
	for headerKey: String in columnKeys:
		var columnConfig:ColumnConfig = ColumnConfig.new(TablePager.CellHeaderResource, TablePager.CellLabelResource, headerKey, rowIndexName)
		
		tableConfig.AddColumnConfig(columnConfig)
		
	# Pass in Callables as callbacks
	var dataPager = autofree(DataPager.new( tableConfig ))
	
	var tablePaged: TablePager = autofree(TABLE_PAGED.instantiate())
	# Initialise the @onready variables 
	tablePaged._ready()
	tablePaged.Initialise(dataPager)
	
	tablePaged.Render()

	
	var tableRowContainer: VBoxContainer = tablePaged.rowContainer
	var childCount: int = tableRowContainer.get_child_count()
	assert_eq(childCount, HEADER_COUNT + pageSize, "Not the right number of Rows in table.")
	
	var headerContainer: Control = tableRowContainer.get_child(HEADER_INDEX)
	var headerColumnNodeArray: Array = headerContainer.get_children()
	var columnCount: int = headerColumnNodeArray.size()
	assert_eq(columnCount, columnKeys.size(), "Header column count should match column keys")
	
	for columnIndex in columnCount:
		var headerNode: CellHeader = headerColumnNodeArray[columnIndex]
		var headerText: String = headerNode._title
		var keyText: String = headerNames[columnIndex]
		
		assert_eq(headerText, keyText, "Header should be a String.capitalized() version of the key name")


func test_TablePager_Paging():
	var pageSize = 5
	var dataSize = 100
	createIntegerData(dataSize)
	
	var tableConfig:TableConfig = autofree(TableConfig.new(SelectPage, RowCount, pageSize))
	# Pick and arbitrary columnKey to be the primaryKey
	var rowIndexName = columnKeys[0]
	for headerKey: String in columnKeys:
		var columnConfig:ColumnConfig = ColumnConfig.new(TablePager.CellHeaderResource, TablePager.CellLabelResource, headerKey, rowIndexName)

		tableConfig.AddColumnConfig(columnConfig)

	# Pass in Callables as callbacks
	var dataPager: DataPager = autofree(DataPager.new( tableConfig ))
	
	var tablePaged: TablePager = autofree(TABLE_PAGED.instantiate())
	# Initialise the @onready variables 
	tablePaged._ready()
	tablePaged.Initialise(dataPager)
	tablePaged.Render()

	checkPageRender(tablePaged)

	dataPager.SetNextPageIndex()
	tablePaged.Render()
#
#	checkPageRender(tablePaged)

func test_TablePager_PagingEdgeCases():
	var pageSize = 5
	var dataSize = 100
	createIntegerData(dataSize)
	
	var tableConfig:TableConfig = autofree(TableConfig.new(SelectPage, RowCount, pageSize))
	# Pick and arbitrary columnKey to be the primaryKey
	var rowIndexName = columnKeys[0]
	for headerKey: String in columnKeys:
		var columnConfig:ColumnConfig = ColumnConfig.new(TablePager.CellHeaderResource, TablePager.CellLabelResource, headerKey, rowIndexName)

		tableConfig.AddColumnConfig(columnConfig)

	# Pass in Callables as callbacks
	var dataPager: DataPager = autofree(DataPager.new( tableConfig ))
	
	var tablePaged: TablePager = autofree(TABLE_PAGED.instantiate())
	# Initialise the @onready variables 
	tablePaged._ready()
	tablePaged.Initialise(dataPager)
	tablePaged.Render()

	var currentPageIndex = dataPager.SetPageIndex(-1)
	assert_eq(0, currentPageIndex, "Should clamp page index")

	@warning_ignore("integer_division")
	var lastPage = dataSize / pageSize
	currentPageIndex = dataPager.SetPageIndex(lastPage)
	assert_eq(0, currentPageIndex, "Invalid page returns current page")

	var lastValidIndex = lastPage - 1
	currentPageIndex = dataPager.SetPageIndex(lastValidIndex)
	assert_eq(lastValidIndex, currentPageIndex, "Last page should return a valid index")

	currentPageIndex = dataPager.SetNextPageIndex()
	assert_eq(lastValidIndex, currentPageIndex, "Next page after last valid page should return last valid page")



func test_TablePager_Sorting():
	var pageSize = 5
	var dataSize = 100
	createIntegerData(dataSize)
	
	var tableConfig:TableConfig = autofree(TableConfig.new(SelectPage, RowCount, pageSize))
	# Pick and arbitrary columnKey to be the primaryKey
	var rowIndexName = columnKeys[0]
	for headerKey: String in columnKeys:
		var columnConfig:ColumnConfig = ColumnConfig.new(TablePager.CellHeaderResource, TablePager.CellLabelResource, headerKey, rowIndexName)

		tableConfig.AddColumnConfig(columnConfig)

	# Pass in Callables as callbacks
	var dataPager: DataPager = autofree(DataPager.new( tableConfig ))
	
	var tablePaged: TablePager = autofree(TABLE_PAGED.instantiate())
	# Initialise the @onready variables 
	tablePaged._ready()
	tablePaged.Initialise(dataPager)
	tablePaged.Render()

	var sortColumnDataOffset = 1
	var sortColumnIndex = 1
	var sortColumnName = columnKeys[sortColumnIndex]
	dataPager.SetSortColumn(sortColumnName)
	checkPageRender(tablePaged, sortColumnIndex, sortColumnDataOffset)


	dataPager.SetNextPageIndex()
	tablePaged.Render()

	checkPageRender(tablePaged, sortColumnIndex, sortColumnDataOffset)


######################################################################################
#### TEST SUPPORT METHODS
######################################################################################

func checkPageRender(tablePaged: TablePager, columnIndex: int = 0, sortOffset:int = 0):
	var dataPager: DataPager = tablePaged._dataPager
	var pageSize = dataPager._pageSize
	var tableRowContainer: VBoxContainer = tablePaged.rowContainer
	var childCount: int = tableRowContainer.get_child_count()
	assert_eq(childCount, HEADER_COUNT + pageSize, "Not the right number of Rows in table.")
	
	var currentPage = dataPager._pageIndexCurrent
	for rowIndex in range(HEADER_COUNT, childCount, 1):
		var rowContainer: Control = tableRowContainer.get_child(rowIndex)
		var rowColumnNodeArray: Array = rowContainer.get_children()
		var columnCount: int = rowColumnNodeArray.size()
		assert_eq(columnCount, columnKeys.size(), "Row column count should match column keys")
	
		# Beacause of the way the data was generated, 
		# we can predict the first column == dataIndex
		var dataRowIndex = rowIndex - HEADER_COUNT
		var predictedDataValue: int = pageSize * currentPage + dataRowIndex + sortOffset
		var cellNode: CellBase = rowColumnNodeArray[columnIndex]
		var cellValue: int = int(cellNode._columnValue)
		
		assert_eq(cellValue, predictedDataValue, "Page %d Value in Row %d should match predicted data" % [currentPage, dataRowIndex])

#######################################################################
## CREATE FAKE DATA ARRAY

func createIntegerData(rowCount: int):
	dataArray = []
	
	for rowIndex in rowCount:
		var dataRow: Dictionary = _createIntegerRow(rowIndex)
		dataArray.append(dataRow)
	
func _createIntegerRow(rowIndex) -> Dictionary:
	var dataRow: Dictionary = {}
	var keyCount: int = columnKeys.size()
	
	for keyIndex: int in keyCount:
		var key = columnKeys[keyIndex]
		var value:int = rowIndex + keyIndex
		dataRow[key] = value
		
	return dataRow

func SelectPage(pageSize: int, pageIndex: int, sortKey: String = "", ascending: bool = true ) -> Array[Dictionary]:
	if sortKey in columnKeys && lastSortKey != sortKey && lastSortValue != ascending:
		dataArray.sort_custom( 
			# Use a Lambda so 'ascending' and 'sortKey' variables can be passed in
			func(a,b) -> bool: 
				var aValue = a[sortKey]
				var bValue = b[sortKey]
				var lessThan: bool = aValue <= bValue if ascending else aValue >= bValue
				return  lessThan
		)
		lastSortValue = ascending
		lastSortKey = sortKey
		
	var startIndex = pageIndex * pageSize
	var endIndex = startIndex + pageSize
	return dataArray.slice(startIndex, endIndex, 1, true)

func RowCount() -> int:
	return dataArray.size()
