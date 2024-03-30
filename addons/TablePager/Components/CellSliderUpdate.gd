extends CellBase
class_name CellSliderUpdate

# Overrides that can be passed in ColumnConfig
const COLUMN_CONFIG_MIN_SLIDER_VALUE = "column_config_min_slider_value"
const COLUMN_CONFIG_MAX_SLIDER_VALUE = "column_config_max_slider_value"



const DEFAULT_MIN_SLIDER_VALUE = 0.0
const DEFAULT_MAX_SLIDER_VALUE = 100.0

var min_slider_value = DEFAULT_MIN_SLIDER_VALUE
var max_slider_value = DEFAULT_MAX_SLIDER_VALUE

var trackingMouse = false
var startMousePostion: float
var startprogressPostion: float

@onready var progress_bar = %ProgressBar

var _celUpdatedSignal: Signal

func Initialise(columnValue: Variant, columnConfig: ColumnConfig):
	SetBaseProperties(columnValue, columnConfig)
	# OPTIONAL CONFIGURATION
	if columnConfig.HasCellConfig(ColumnConfig.CELL_UPDATED_SIGNAL):
		_celUpdatedSignal = columnConfig.GetCellConfig(ColumnConfig.CELL_UPDATED_SIGNAL)
	if columnConfig.HasCellConfig(CellSliderUpdate.COLUMN_CONFIG_MIN_SLIDER_VALUE):
		min_slider_value = columnConfig.GetCellConfig(CellSliderUpdate.COLUMN_CONFIG_MIN_SLIDER_VALUE)
	if columnConfig.HasCellConfig(CellSliderUpdate.COLUMN_CONFIG_MAX_SLIDER_VALUE):
		max_slider_value = columnConfig.GetCellConfig(CellSliderUpdate.COLUMN_CONFIG_MAX_SLIDER_VALUE)



# Called when the node enters the scene tree for the first time.
func _ready():
	_update_slider()

func _update_slider():
	var progressValue := float(_columnValue)
	if progress_bar:
		progress_bar.value = clamp(progressValue, min_slider_value, max_slider_value)
		


func _process(_delta):
	if trackingMouse:
		var controlRect: Rect2 = get_global_rect()
		var controlSize: float = controlRect.size.x
		var controlPostionX: float = controlRect.position.x
		
		var maxSize = progress_bar.max_value
		var pixelsPerStep = controlSize/maxSize
	
		var mousePostionX: float = get_global_mouse_position().x
		var mouseSliderValue = (mousePostionX - controlPostionX) / pixelsPerStep
		
		_columnValue = clamp(mouseSliderValue, min_slider_value, max_slider_value)
		_update_slider()



func _on_button_button_down():
	# Start dragging progress bar
	var mousePostionX: float = get_global_mouse_position().x
	startMousePostion = mousePostionX
	startprogressPostion = progress_bar.value
	trackingMouse = true


func _on_button_button_up():
	if _celUpdatedSignal:
		_celUpdatedSignal.emit(_columnName, _rowIndex, _columnValue)
	trackingMouse = false
