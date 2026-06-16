# Improved Bottle Management

This use case improves bottle list management by separating bottles currently in inventory from bottles that have already been disposed of.

## Bottle Index

The bottle index page should show only bottles that are currently in inventory.

Use the existing inventory definition:

* A bottle is in inventory if `disposal_date` is `nil`.
* A bottle is not in inventory if `disposal_date` is present.

The bottle index should continue to:

* show only bottles visible to the current user
* sort by purchase date descending by default
* include the existing search, sorting, pagination, tasted indicator, and action links
* preserve the existing "New bottle" button

Because this page will only show bottles in inventory, remove the "In Inventory" column from the main bottle index table.

## Disposed Bottles Page

On the bottle index page, add a button labelled "Disposed Bottles".

The button should go to a new page listing bottles that are no longer in inventory.

The disposed bottles page should:

* show only bottles visible to the current user
* show only bottles where `disposal_date` is present
* sort by `disposal_date` descending by default
* include the existing search, sorting, pagination, tasted indicator, and action links where appropriate
* include a way to return to the main bottle index page

The disposed bottles table should include:

* Inventory
* Wine
* Purchase Date
* Source
* List Price
* Discount Price
* Disposal Date
* Disposal Method
* Tasted
* Actions

Do not show a Location column on this page unless it is already useful for disposed bottles.

## Disposal Method Filter

On the disposed bottles page, add a drop-down filter for disposal method.

The drop-down should include:

* All
* every allowed value from `Bottle::DISPOSAL_METHODS`

Selecting "All" should show all disposed bottles.

Selecting a disposal method should show only disposed bottles with that disposal method.

The filter should preserve the default disposed-bottle sort order unless the user has sorted the table directly in the UI.

Use the UI capitalization already defined for disposal methods.

## Routing And Controller Behavior

Implement the disposed bottles page as a top-level bottle collection action.

The route should use normal Rails route conventions and should not require a bottle id.

The controller should keep the main inventory query and the disposed query separate enough that future behavior can diverge.

## Tests

Build tests for:

* the main bottle index excludes disposed bottles
* the main bottle index includes bottles in inventory
* the disposed bottles page excludes bottles in inventory
* the disposed bottles page includes disposed bottles
* disposed bottles are sorted by disposal date descending by default
* filtering by disposal method limits the disposed bottles table appropriately
* selecting "All" does not filter by disposal method

Run the relevant Rails tests after implementation.
