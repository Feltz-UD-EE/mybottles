# Multi-Bottle Purchase

It is common to purchase multiple bottles of the same wine and vintage at the same time. Bottle creation should support this without making the user submit the same form repeatedly.

## Bottle Create Form

Add a "Quantity" field to the bottle create form.

The quantity field should:

* be shown only on the new/create form
* not be shown on the edit/update form
* accept integer values greater than or equal to 1
* default to 1

Quantity is a form-only value. Do not add a `quantity` column to the bottles table.

## Creating Multiple Bottles

When the create form is submitted, create a number of bottles equal to the submitted quantity. Call this number `N` for this use case.

All created bottles should duplicate the submitted bottle values except for `personal_inventory`.

If `personal_inventory` is blank:

* create `N` bottles with `personal_inventory` blank
* allow the existing automatic inventory code behavior to generate distinct `auto_inventory` values for each bottle

If `personal_inventory` is present:

* create `N` bottles
* only the first bottle should receive the submitted `personal_inventory` value
* the other `N - 1` bottles should have `personal_inventory` set to `nil`
* the other `N - 1` bottles should still receive generated `auto_inventory` values if the existing automatic inventory behavior applies

Use a database transaction so that either all `N` bottles are created or none of them are created.

If any bottle cannot be created, render the new form with validation errors and do not persist a partial set of bottles.

## Confirmation Messages

If exactly one bottle is created, keep the existing confirmation language unless implementation needs a minor wording adjustment.

If more than one bottle is created and `personal_inventory` is blank, the confirmation message should state how many bottles were created.

If more than one bottle is created and `personal_inventory` is present, the confirmation message should state:

* how many bottles were created
* that only the first bottle has the personal inventory code
* that the remaining `N - 1` bottles do not have their personal inventory field completed
* that the user should not print labels for those remaining bottles until after updating their personal inventory fields

Use "personal inventory code" in user-facing text.

## Redirect Behavior

After successful creation, redirect to the show page for the first created bottle.

The first created bottle is:

* the only bottle created, when `N` is 1
* the bottle with the submitted `personal_inventory` value, when `personal_inventory` is present
* the first bottle created by the transaction, when `personal_inventory` is blank

## Label Printing

Respect the user's existing default label-printing preference.

If the user's default is not to automatically print labels, do not automatically print labels after creation.

If the user's default is to automatically print labels and `personal_inventory` is blank:

* automatically print labels for all `N` bottles created
* each label should use that bottle's generated `auto_inventory` display value

If the user's default is to automatically print labels and `personal_inventory` is present:

* automatically print only the label for the first bottle
* do not automatically print labels for the remaining `N - 1` bottles

The implementation may use a batch-label print route or extend the existing print hook, but the browser behavior should be clear to the user and should not require manually opening each label when automatic printing is enabled.

## Tests

Build tests for:

* the new bottle form shows a quantity field defaulting to 1
* the edit bottle form does not show a quantity field
* quantity must be an integer greater than or equal to 1
* creating with quantity 1 preserves existing single-bottle behavior
* creating with quantity greater than 1 and blank `personal_inventory` creates `N` bottles
* each created bottle receives the duplicated submitted values
* each created bottle receives a distinct generated `auto_inventory` value when applicable
* creating with quantity greater than 1 and present `personal_inventory` puts that value only on the first bottle
* the remaining `N - 1` bottles have blank `personal_inventory`
* the warning confirmation message appears when `personal_inventory` is present and quantity is greater than 1
* failed multi-bottle creation does not persist a partial set of bottles
* automatic label printing prints all `N` labels when `personal_inventory` is blank
* automatic label printing prints only the first label when `personal_inventory` is present

Run the relevant Rails tests after implementation.
