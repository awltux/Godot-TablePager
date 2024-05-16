@icon("res://addons/tablepager/Icons/TablePager.svg")

extends VBoxContainer
class_name TablePager


# YouTube Design Reference: https://www.youtube.com/watch?v=Kz517iDaUtU

const INITIALISE_METHOD_NAME = "Initialise"
const RowCellContainerResource: PackedScene = preload("./Components/RowCellContainer.tscn")

# SOME EXAMPLE CELL WIDGETS
const CellLabelResource: PackedScene = preload("./Components/CellLabel.tscn")
const CellHeaderResource: PackedScene = preload("./Components/CellHeader.tscn") 
const CellSliderUpdateResource: PackedScene = preload("./Components/CellSliderUpdate.tscn")
const CellCheckButtonUpdateResource: PackedScene = preload("./Components/CellCheckButtonUpdate.tscn")

const ENUM_SORT_ORDER_COUNT = 3

enum EnumSortOrder {
	NONE = 0,
	ASCENDING = 1,
	DESCENDING = 2,
}

@onready var headerContainer = %HeaderContainer
@onready var rowContainer = %RowContainer
@onready var page_progress_label = %PageProgressLabel
@onready var search_text_entry = %SearchTextEntry

# Navigation Buttons
@onready var button_skip_back     = %ButtonSkipBack
@onready var button_previous      = %ButtonPrevious
@onready var button_next          = %ButtonNext
@onready var button_skip_forwards = %ButtonSkipForwards


var _dataPager: DataPager

func Initialise(tableConfig: TableConfig):
	_dataPager = DataPager.new( tableConfig )

	if is_inside_tree():

		var sortColumnSignal: Signal = _dataPager._tableConfig.columnSortSignal
		if not sortColumnSignal.is_connected(_handleColumnSortSignal):
			sortColumnSignal.connect(_handleColumnSortSignal)

		var widthChangedSignal: Signal = _dataPager._tableConfig.widthChangedSignal
		if not widthChangedSignal.is_connected(_handleWidthChangedSignal):
			widthChangedSignal.connect(_handleWidthChangedSignal)
 
func _exit_tree():

	if _dataPager:
		var sortColumnSignal: Signal = _dataPager._tableConfig.columnSortSignal
		if sortColumnSignal:
			sortColumnSignal.disconnect(_handleColumnSortSignal)

		var widthChangedSignal: Signal = _dataPager._tableConfig.widthChangedSignal
		if widthChangedSignal:
			widthChangedSignal.disconnect(_handleWidthChangedSignal)

func GetSearchText() -> String:
	return _dataPager._searchText

func ResetDataCount(dataCount: int):
	_dataPager.resetDataCount(dataCount)

func _handleWidthChangedSignal(columnName: String, columnWidth: float):
	var columnConfig: ColumnConfig = _dataPager._tableConfig.GetColumnConfig(columnName)
	columnConfig.customMinimumSize = columnWidth
	columnConfig.expandHorizontal = false
	
func _handleColumnSortSignal(columnName: String):
	assert(columnName in _dataPager.GetColumnKeys(), "Invalid Sort columnName: %s" % [columnName])
	_dataPager._sortColumnKey = columnName
	_dataPager._sortColumnOrder = (_dataPager._sortColumnOrder + 1) % ENUM_SORT_ORDER_COUNT
	Render()


func Render():
	# Remove all rows - not header
	var rowArray: Array = rowContainer.get_children()
	var rowCount: int = rowArray.size()
	for rowIndex in range(0, rowCount, 1):
		var childNode: Node = rowArray[rowIndex]
		rowContainer.remove_child(childNode)

	if _dataPager:
		var currentPageData: Array[Dictionary] = _dataPager.GetPageDataCurrent()
		var _row_count: int = currentPageData.size()
		var columnKeyArray: Array = _dataPager.GetColumnKeys()

		# Create the headers
		if headerContainer.get_child_count() == 0:
			var headerCellContainer: RowCellContainer = RowCellContainerResource.instantiate()
			headerContainer.add_child(headerCellContainer)
			for columnKey in columnKeyArray:
				var headerCell = CellHeaderResource.instantiate()
				if headerCell.has_method(INITIALISE_METHOD_NAME):
					var columnConfig: ColumnConfig = _dataPager.GetColumnConfig(columnKey)
					var emptyRowData = {}
					headerCell.Initialise(emptyRowData, columnConfig)

				headerCellContainer.add_child(headerCell)
			
			
		# Add each row to the table
		for rowData: Dictionary in currentPageData:
			var rowCellContainer: RowCellContainer = RowCellContainerResource.instantiate()
			# rowCellContainer.add_theme_color_override("bg_color", Color.CRIMSON)

			rowContainer.add_child(rowCellContainer)
			
			# Add each column to the current row
			var columnKeyCount = columnKeyArray.size()
			for columnKeyIndex in columnKeyCount:
				var columnKey: String = columnKeyArray[columnKeyIndex]

				var columnConfig: ColumnConfig = _dataPager.GetColumnConfig(columnKey)
				var columnType: PackedScene = columnConfig.cellPackedScene
				var cellInstance: CellBase = columnType.instantiate()

				if cellInstance.has_method(INITIALISE_METHOD_NAME):
					cellInstance.Initialise(rowData, columnConfig)

				if columnConfig.customMinimumSize != ColumnConfig.DEFAULT_WIDTH_PX:
					var customMinimumSize = columnConfig.customMinimumSize
					var expandHorizontal = columnConfig.expandHorizontal
					cellInstance.custom_minimum_size = Vector2(customMinimumSize, 0)
					if expandHorizontal:
						cellInstance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					else:
						cellInstance.size_flags_horizontal = Control.SIZE_FILL

				rowCellContainer.add_child(cellInstance)

		SetPageProgressLabel()


func _on_button_skip_back_pressed():
	_dataPager.SetSkipPreviousPageIndex()
	Render()


func _on_button_previous_pressed():
	_dataPager.SetPreviousPageIndex()
	Render()


func _on_button_next_pressed():
	_dataPager.SetNextPageIndex()
	Render()


func _on_button_skip_forwards_pressed():
	_dataPager.SetSkipNextPageIndex()
	Render()
	
func SetPageProgressLabel():
	if _dataPager._pageMax == 0:
		page_progress_label.text = "Page 0 of 0"
	else:
		page_progress_label.text = "Page %d of %d" % [_dataPager._pageIndexCurrent + 1, _dataPager._pageMax]

	if _dataPager._pageMax == 0 || (_dataPager._pageMax == 1 && _dataPager._pageIndexCurrent == 0):
		button_skip_back.disabled = true
		button_previous.disabled = true
		button_next.disabled = true
		button_skip_forwards.disabled = true
	else:
		button_skip_back.disabled = false
		button_previous.disabled = false
		button_next.disabled = false
		button_skip_forwards.disabled = false
		

func _on_search_text_entry_text_changed(searchText):
	var currentSearchText: String = _dataPager._searchText
	if currentSearchText != searchText:
		_dataPager.SetSearchText(searchText)
		Render()

func _on_reset_button_pressed():
	search_text_entry.text = ""
	_dataPager.SetSearchText("")
	Render()


