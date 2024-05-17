# Table Pager
Table pager is a Godot 4.x plugin that displays Array[Dictionary] data 
as an in-game pageable and sortable table.

[GitHub repository](https://github.com/awltux/Godot-TablePager)
# Features
* Uses data in the Array[Dictionary] format, as used by the SQLite plugin 
* Data Pager displays data a page at a time
  * Step forward or backward a page at a time
  * Skip forward or backward several pages at a time
  * Displays the current page and the end page using "N of M"
* Sortable columns
  * Click header for Ascending, Descending and DB native
* Resizable columns
  * Initial width can be set
  * Columns can be dragged to a new size.
* Column Headers
  * Default name is the column name used in the Dictionary
  * Header name can be overridden.
* Extend CellBase to create other types of table Cells
* Update data in DB:
  * progressBar and CheckButtons can be used to update the DB directly.
* Uses Signals to return data to the application.
* Example code
  * Example includes basic theme

# Installation
Either:
* Search for TablePager in Godot AssetLibrary and install
* Download the latest version of the zip file from [GitHub releases](https://github.com/awltux/Godot-TablePager/releases) and import the zip using the Godot AssetLibrary tab.

# Usage
Add an instance of the TablePager scene into the Node tree.

Use the parent Node script to initialise the TablePager Node

## Callback methods
Define two methods, one to return a pageSize of Array[Dictionary] data, the second to return the dataSize.
The names of the methods are not relevant, but they must conform to the method parameters.

```
### pageSize: How many rows to be returned
### pageIndex: Which page of data to return; between 0 and ceil(dataSize/float(pageSize))
### sortKey: The column that the data should be sorted by; must match a key in the data set.
### sortOrder: Must be one of three values defined by the enum DataPager.EnumSortOrder
###    * NONE: Use database natural order
###    * ASCENDING: incrementing column values
###    * DESCENDING: decrementing column values
func SelectPageOfRowData(
		pageSize: int,
		pageIndex: int,
		sortKey: String = "",
		sortOrder: DataPager.EnumSortOrder = DataPager.EnumSortOrder.NONE
		) -> Array[Dictionary]:
	### Populate with a DB query and return the result
	### Don't forget that you can put additional filtering here like selecting
	### specific players or levels to make the table context specific. 
	return []

# Return the total size of the data being queried.
func GetDataCount() -> int:
	return dataSize
```

## Create a TableConfig
Use these callbacks to create an instance of TableConfig
```

var tableConfig: TableConfig
var pageSize: int = 10

func _ready():
	### Configure the callbacks used to get data pages and the desired size of each page.
	tableConfig = TableConfig.new(
			SelectPageOfRowData, 
			GetDataCount, 
			pageSize)

...
```

## Add ColumnConfig to TableConfig
Each table cell is defined as a Scene component that inherits from CellBase.
The TablePager script defines a set of PackedScene objects that can be 
used to define each cell. Developing table cells is relatively easy, and makes the TablePager quite extensible.

Current types of cells include:
* TablePager.CellHeaderResource: A header cell supports column width resizing and column sorting Signals.
* TablePager.CellLabelResource: Simple Label cell that can generate 'selected' Signals
* TablePager.CellCheckButtonUpdateResource: Simple CheckButton that fires 'changed' Signals
* TablePager.CellSliderUpdateResource: Adjustable Slider that fires 'changed' Signals

**NOTE**: Please feel free to submit any additional Cells you create and I'll try to include them in future releases.

```
	### Parameters are as follows:
	### The header cell is placed at the top of the table
	### The column cell is a specialised scene object that displays each column/row data
	### The column name used to read the value from the row data and then populate the cell component
	### The primary key for a row of data is used when creating signals such as
	### Clicked or Changed and allows the developer to map the event back to the database row.
	var labelColumnConfig:ColumnConfig = ColumnConfig.new(
			# Set the Header widget
			TablePager.CellHeaderResource, 
			TablePager.CellLabelResource, 
			"label_string", 
			"label_primary_key")
	### Additional, cell-specific parameters are passed as a dictionary of items
	### See Examples and Cell component scripts for full list of configuration parameters

	### This adds a Signal object to send 'selected' events to the application.
	labelColumnConfig.AddCellConfig(ColumnConfig.CELL_SELECTED_SIGNAL, CellSelectedSignal)

	### Add the ColumnConfig to the TableConfig
	### NOTE: Columns are displayed in the order they are added to the TableConfig
	tableConfig.AddColumnConfig(labelColumnConfig)

	### Define more columns as required...
```

## DataPager
The TableConfig is passed to a DataPager that selects the data and passes it to the TablePager for display.
```
	### Create a DataPager using the TableConfig
	var dataPager: DataPager = DataPager.new( tableConfig )
	
	### Tell the TablePager Node where to get its data pages from   
	tablePager.Initialise(dataPager)

	### Display the current page of sorted data.   
	tablePager.Render()
```

# Tips & Tricks

## Tennant queries
If the table needs to display a subset of the data e.g. results for a particular player, define a select filter in the callback methods.

## Themes
There are some example themes included. No theme is applied by default, but you can apply the example theme to the TablePager or define your own.
A primary table theme is generally all that's required. This is only because currently the header is defined as buttons and the column cells aren't.
If a custom column cell uses buttons, a specialised theme will be needed for headers.
