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


@onready var headerContainer = %HeaderContainer
@onready var rowContainer = %RowContainer
@onready var page_progress_label = %PageProgressLabel

	
var _dataPager: DataPager

func Initialise(dataPager: DataPager):
	_dataPager = dataPager
	if is_inside_tree():

		var sortColumnSignal: Signal = _dataPager._tableConfig.columnSortSignal
		sortColumnSignal.connect(_handleColumnSortSignal)

		var widthChangedSignal: Signal = _dataPager._tableConfig.widthChangedSignal
		widthChangedSignal.connect(_handleWidthChangedSignal)
 
func _exit_tree():

	var sortColumnSignal: Signal = _dataPager._tableConfig.columnSortSignal
	sortColumnSignal.disconnect(_handleColumnSortSignal)

	var widthChangedSignal: Signal = _dataPager._tableConfig.widthChangedSignal
	widthChangedSignal.disconnect(_handleWidthChangedSignal)

func _handleWidthChangedSignal(columnName: String, columnWidth: float):
	var columnConfig: ColumnConfig = _dataPager._tableConfig.GetColumnConfig(columnName)
	columnConfig.customMinimumSize = columnWidth
	columnConfig.expandHorizontal = false
	
func _handleColumnSortSignal(columnName: String):
	assert(columnName in _dataPager.GetColumnKeys(), "Invalid Sort columnName: %s" % [columnName])
	_dataPager._sortColumnKey = columnName
	_dataPager._sortColumnOrder = (_dataPager._sortColumnOrder + 1) % DataPager.ENUM_SORT_ORDER_COUNT
	Render()


func Render():
	SetPageProgressLabel()
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
	page_progress_label.text = "page %d of %d" % [_dataPager._pageIndexCurrent + 1, _dataPager._pageMax]
