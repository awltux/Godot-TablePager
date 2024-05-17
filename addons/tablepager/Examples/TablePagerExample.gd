extends Control

@onready var tablePager = $TablePager


# A real applicaiton would be using SQLite DB 
var dataArray: Array[Dictionary] = []
var lastSortKey
var lastSortOrder: TablePager.EnumSortOrder
var lastSearchText: String = ""

var pageSize = 15
var dataSize = 155

var tableConfig:TableConfig

signal CellUpdatedSignal(columnName: String, rowIndex: Variant, celValue: Variant)
signal CellSelectedSignal(columnName: String, rowIndex: Variant)
	

func _ready():
	# randomize is used to create Fake DB data 
	randomize()
	
	# Tell the table how to get data and what size each page should be.
	tableConfig = TableConfig.new(
			SelectPageOfRowData, 
			GetDataCount,
			RowColourCallback,
			pageSize)
	
	#######################################
	### Add some columns to the table

	var labelColumnConfig:ColumnConfig = ColumnConfig.new(
			# Set the Header widget
			TablePager.CellHeaderResource, 
			TablePager.CellLabelResource, 
			"label_string", 
			"label_primary_key")
	labelColumnConfig.AddCellConfig(ColumnConfig.CELL_SELECTED_SIGNAL, CellSelectedSignal)
	tableConfig.AddColumnConfig(labelColumnConfig)

	var checkButtonColumnConfig:ColumnConfig = ColumnConfig.new(
			# Set the Header widget
			TablePager.CellHeaderResource, 
			TablePager.CellCheckButtonUpdateResource, 
			"checkButton_state", 
			"checkButton_primary_key")
	checkButtonColumnConfig.AddCellConfig(ColumnConfig.CELL_UPDATED_SIGNAL, CellUpdatedSignal)
	checkButtonColumnConfig.AddCellConfig(ColumnConfig.COLUMN_WIDTH_FIXED, true)
	checkButtonColumnConfig.AddCellConfig(ColumnConfig.COLUMN_WIDTH_PX, 70)
	checkButtonColumnConfig.AddCellConfig(CellHeader.COLUMN_CONFIG_TITLE_OVERRIDE, "Do")
	tableConfig.AddColumnConfig(checkButtonColumnConfig)

	var sliderColumnConfig:ColumnConfig = ColumnConfig.new(
			# Set the Header widget
			TablePager.CellHeaderResource, 
			TablePager.CellSliderUpdateResource, 
			"slider_value", 
			"slider_primary_key")
	sliderColumnConfig.AddCellConfig(ColumnConfig.CELL_UPDATED_SIGNAL, CellUpdatedSignal)
	tableConfig.AddColumnConfig(sliderColumnConfig)

	createSomeFakeData(tableConfig, dataSize)

	
	# Initialise the @onready variables 
	tablePager.Initialise(tableConfig)
	tablePager.Render()

func _enter_tree():
	CellUpdatedSignal.connect(_handle_CellUpdatedSignal)
	CellSelectedSignal.connect(_handle_CellSelectedSignal)

func _exit_tree():
	CellUpdatedSignal.disconnect(_handle_CellUpdatedSignal)
	CellSelectedSignal.disconnect(_handle_CellSelectedSignal)

# TablePager configured to call this function when table cell selected
func _handle_CellSelectedSignal(columnName: String, rowIndex: Variant):
	# fake a DB update
	match columnName:
		"label_string":
			print("selected row %d from column '%s'" % [rowIndex, columnName])

# TablePager configured to call this function when table cell updated
func _handle_CellUpdatedSignal(columnName: String, rowIndex: Variant, cellValue: Variant):
	# fake a DB update

	# Previously sorted column means we have to manually search for the correct rowIndex
	var columnConfig: ColumnConfig = tableConfig.GetColumnConfig(columnName)
	var rowIndexName: String = columnConfig.rowIndexName
	for dataRow: Dictionary in dataArray:
		if dataRow[rowIndexName] == rowIndex:
			match columnName:
				"checkButton_state":
					dataRow[columnName] = cellValue
				"slider_value":
					dataRow[columnName] = int(cellValue)
	pass

func RowColourCallback(rowUuid: String, rowValue: String) -> Color:
	return Color.CHARTREUSE

# TablePager is configured to call this when it needs the a page of data
# A real application would use this to return a page of data from the database
func SelectPageOfRowData(pageSize: int, pageIndex: int, sortKey: String = "", sortOrder: TablePager.EnumSortOrder = TablePager.EnumSortOrder.NONE, searchString: String = "" ) -> Array:
	var filteredData: Array = []
		
	filteredData = GetSearchData(searchString)
	
	# Fake a database lookup
	var columnKeyArray: Array = tableConfig.GetKeys()
	
	var sortParamsChanged = ( lastSortKey != sortKey || lastSortOrder != sortOrder )
	if sortKey in columnKeyArray && sortParamsChanged:
		filteredData.sort_custom( 
			# Use a Lambda so 'ascending' and 'sortKey' variables can be passed in
			func(a,b) -> bool: 
				var aValue = a[sortKey]
				var bValue = b[sortKey]
				var lessThan: bool
				if typeof(aValue) == TYPE_BOOL && typeof(bValue):
					# boolean requires special compare
					lessThan = aValue && not bValue if sortOrder else not aValue && bValue
				else:
					lessThan = aValue <= bValue if sortOrder else aValue >= bValue
				return  lessThan
		)
		lastSortOrder = sortOrder
		lastSortKey = sortKey
		
	var startIndex = pageIndex * pageSize
	var endIndex = startIndex + pageSize
	return filteredData.slice(startIndex, endIndex, 1, true)

# TablePager is configured to call this during initialisation to find the unfiltered length of the data
func GetDataCount(searchText: String = "") -> int:
	var searchData: Array = GetSearchData(searchText)
	return searchData.size()
	
#######################################################################
## CREATE FAKE DATA ARRAY

func GetSearchData(searchString) -> Array:
	var filteredData: Array = []
	# Apply Search to static data array
	var currentSearchString: String = tablePager.GetSearchText()
	if currentSearchString.is_empty():
		filteredData = dataArray
	else:
		for dataRow: Dictionary in dataArray:
			var columnString: String = dataRow["label_string"].to_lower()
			if columnString.contains(currentSearchString.to_lower()):
				filteredData.append(dataRow)

	if lastSearchText.to_lower() != currentSearchString.to_lower():
		lastSearchText = currentSearchString
		# Need to tell the DataPager that the data length has changed.
		tablePager.ResetDataCount(filteredData.size())

	return filteredData

func createSomeFakeData(tableConfig:TableConfig, rowCount: int):
	dataArray = []
	var columnKeyArray: Array = tableConfig.GetKeys()
	
	for rowIndex in rowCount:
		var dataRow: Dictionary = {}

		for columnKey in columnKeyArray:
			var columnConfig: ColumnConfig = tableConfig.GetColumnConfig(columnKey)
			var rowIndexName: String = columnConfig.rowIndexName
			match columnConfig.cellPackedScene:
				TablePager.CellLabelResource:
					dataRow[columnKey] = _createRandomLabelText()
					dataRow[rowIndexName] = rowIndex
				TablePager.CellCheckButtonUpdateResource:
					dataRow[columnKey] = randi() % 1 as bool
					dataRow[rowIndexName] = rowIndex
				TablePager.CellSliderUpdateResource:
					dataRow[columnKey] = randi() % 100
					dataRow[rowIndexName] = rowIndex

		dataArray.append(dataRow)
	
func _createRandomLabelText() -> String:
	var maxDataIndex = STATIC_TEXT_DATA.size()
	var returnText = STATIC_TEXT_DATA[randi() % maxDataIndex][0]
	returnText += " " + STATIC_TEXT_DATA[randi() % maxDataIndex][1]
	returnText += " " + STATIC_TEXT_DATA[randi() % maxDataIndex][2]
	return returnText
	
# To generate random text for fake DB
const STATIC_TEXT_DATA: Array[Array] = [
	["Dogs","love","toys"],
	["Cats","prefer","naps"],
	["Kids","need","snacks"],
	["Books","fill","rooms"],
	["Art","inspires","minds"],
	["Food","nourishes","bodies"],
	["Music","soothes","souls"],
	["Flowers","bloom","bright"],
	["Mountains","rise","tall"],
	["Rivers","flow","deep"],
	["Oceans","hold","mysteries"],
	["Stars","twinkle","brightly"],
	["Clouds","drift","softly"],
	["Winds","whisper","secrets"],
	["Raindrops","fall","gently"],
	["Snowflakes","dance","gracefully"],
	["Birds","sing","sweetly"],
	["Bees","pollinate","flowers"],
	["Trees","clean","air"],
	["Fish","swim","freely"],
	["Horses","run","swiftly"],
	["Trains","rush","by"],
	["Ships","sail","smoothly"],
	["Cars","drive","fast"],
	["Bikes","ride","swiftly"],
	["Planes","fly","high"],
	["Boats","float","gently"],
	["Subways","run","underground"],
	["Trucks","carry","goods"],
	["Bridges","connect","lands"],
	["Homes","house","families"],
	["Schools","teach","knowledge"],
	["Libraries","store","books"],
	["Markets","sell","goods"],
	["Factories","make","products"],
	["Farms","grow","produce"]
]
