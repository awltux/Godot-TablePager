extends CellBase
class_name CellHeader

const COLUMN_CONFIG_TITLE_OVERRIDE = "column_config_title_override"

const DRAG_AREA_WIDTH = 10
const MINIMUM_COLUMN_WIDTH = 35

@onready var button = %Button

var _title
var _columnSortSignal: Signal

var _columnDragging: bool = false
var _columnStartWidth: float
var _columnStartPos: float

var _updatingMouseIcon: bool = false

func Initialise(rowData: Dictionary, columnConfig: ColumnConfig):
	SetBaseProperties(rowData, columnConfig)
	_columnSortSignal = columnConfig.columnSortSignal
	
	# OPTIONAL SIGNALS
	if columnConfig.HasCellConfig(COLUMN_CONFIG_TITLE_OVERRIDE):
		_title = columnConfig.GetCellConfig(COLUMN_CONFIG_TITLE_OVERRIDE)
	else:
		_title = _columnName.capitalize()
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	button.text = _title

func _process(_delta):
	# Are we resizing the header width?
	if _columnDragging:
		if button.is_pressed():
			var delatPos: float = get_global_mouse_position().x - _columnStartPos
			var newSize: float = max(_columnStartWidth + delatPos, MINIMUM_COLUMN_WIDTH)
			_widthChangedSignal.emit(_columnName, newSize)
		else:
			# Sometimes the button-up event is missed
			_on_button_up()
	# If we are hovering over the header Cell, check the type of cursor to display
	if _updatingMouseIcon:
		var _mouseX = get_global_mouse_position().x
		if mouse_in_drag_area(_mouseX):
			button.set_default_cursor_shape(CursorShape.CURSOR_HSIZE)
		else:
			button.set_default_cursor_shape(CursorShape.CURSOR_ARROW)

func mouse_in_drag_area(mouseX: float) -> bool:
	var insideDragArea: bool = false
	var peerNodeArray: Array[Node] = get_parent().get_children()
	var lastNodeIndex = peerNodeArray.size() - 1
	var lastColumn: bool = (self == peerNodeArray[lastNodeIndex])
	# Don't support resizing the last column
	if not lastColumn:
		var buttonRect: Rect2 = button.get_global_rect()
		var buttonPos: float = buttonRect.position.x
		var buttonWidth: float = buttonRect.size.x
		var rightEdgeOfDragArea: float = buttonPos + buttonWidth
		var leftEdgeOfDragArea: float = buttonPos + buttonWidth - DRAG_AREA_WIDTH
		insideDragArea = mouseX > leftEdgeOfDragArea && mouseX < rightEdgeOfDragArea
	return insideDragArea
	
func _on_button_down():
	var _mouseX = get_global_mouse_position().x
	if mouse_in_drag_area(_mouseX):
		_columnStartWidth = size.x
		_columnStartPos = _mouseX
		_columnDragging = true
	else:
		var customMinimumSize = _customMinimumSize
		var expandHorizontal = _expandHorizontal
		_columnSortSignal.emit(_columnName)

func _on_button_up():
	_columnDragging = false


func _on_button_mouse_entered():
	_updatingMouseIcon = true
	button.set_default_cursor_shape(CursorShape.CURSOR_ARROW)


func _on_button_mouse_exited():
	_updatingMouseIcon = false
	if not _columnDragging:
		button.set_default_cursor_shape(CursorShape.CURSOR_ARROW)
