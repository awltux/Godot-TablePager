# Table Pager
Table pager is a Godot 4.x plugin that displays Array[Dictionary] data in a table format.

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
* Unit Tests
  * Install GUT to run a set of basic tests
