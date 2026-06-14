# Extended Tasting Notes

## Overview

Extend tasting note visibility throughout the wine, vintage, and bottle UI so that tasting history is easier to compare
across related objects.

This use case does not create new database tables. It adds relationship-aware query helpers, controller data loading,
and view elements using the existing relationships among:

* Producer
* Wine
* Vintage
* Bottle
* Tasting Note

Tasting notes remain personal user-owned data. They should continue to use the ownership and visibility rules already
implemented for private user-owned records.

Dates should display as `YYYY-MM-DD`.

## Existing Relationship Context

Tasting notes use a polymorphic `tasteable` relationship.

Current valid tasteable targets:

* Bottle
* Vintage

A tasting note attached to a bottle is still a note about the bottle's vintage and wine.

A tasting note attached directly to a vintage is still a note about that vintage and wine.

Use helper methods or scopes to collapse these relationships for display and filtering. Do not duplicate wine or vintage
foreign keys onto tasting notes in this use case unless the existing polymorphic relationship proves insufficient.

## Bottle Show Page

On a bottle show page, list tasting notes for:

* the current bottle, and
* any other bottle of the same vintage, and
* tasting notes attached directly to the same vintage.

Sort the list by tasting note date descending.

The purpose of this section is to show the tasting history for the specific vintage represented by the bottle. If the
same vintage has multiple bottles, tasting notes from all of those bottles should be visible from any bottle in that
vintage.

The list should identify which bottle or vintage each tasting note is attached to.

Suggested table columns:

* Date
* Attachment
* Overall
* Score
* Buy
* Actions

The `Attachment` value should distinguish between:

* the current bottle,
* another bottle of the same vintage, and
* a vintage-level tasting note.

The action column should include at least a link to the tasting note show page.

If there are no tasting notes in this scope, leave the section empty or show the existing project-standard empty state.

## Vintage Show Page

On a vintage show page, list tasting notes for the vintage's wine, regardless of vintage.

Include tasting notes attached to:

* any bottle belonging to any vintage of the same wine, and
* any vintage belonging to the same wine.

Do not restrict this list to tasting notes for the current vintage only.

Sort the table by:

1. vintage descending
2. tasting note date descending

The purpose is to let collectors compare the performance and characteristics of a wine vintage by vintage.

Suggested table columns:

* Vintage
* Date
* Attachment
* Overall
* Score
* Buy
* Actions

The action column should include at least a link to the tasting note show page.

## Wine Show Page

On a wine show page, list tasting notes for that wine, regardless of vintage.

Include tasting notes attached to:

* any bottle belonging to any vintage of that wine, and
* any vintage belonging to that wine.

Sort the table by:

1. vintage descending
2. tasting note date descending

Use the same table structure and relationship logic as the vintage show page.

## Index Page Tasted Indicator

Add a `Tasted` column to the following index pages:

* Wine index
* Vintage index
* Bottle index

For each row, show a green checkmark icon if there are any tasting notes in the relevant relationship scope.

Do not show helper text when there are no tasting notes. A blank cell is sufficient.

### Wine Index Scope

A wine has been tasted if there is at least one tasting note attached to:

* any bottle belonging to any vintage of that wine, or
* any vintage belonging to that wine.

### Vintage Index Scope

A vintage has been tasted if there is at least one tasting note attached to:

* any bottle belonging to that vintage, or
* that vintage directly.

### Bottle Index Scope

A bottle has been tasted if there is at least one tasting note attached to:

* that bottle directly.

For the bottle index only, do not mark a bottle as tasted merely because another bottle of the same vintage has a tasting
note. The indicator should answer whether this specific physical bottle has a tasting note.

## UI Requirements

Use the existing dynamic table pattern on index pages.

The green checkmark icon should be accessible. It should have an appropriate accessible label such as `Tasted`.

Use the existing project icon/button style where possible. Do not introduce a new icon library for this feature.

Do not add visible explanatory helper text unless needed by an existing project pattern.

## Implementation Notes

Prefer model-level scopes or query helper methods over duplicating ad hoc query logic in views.

Suggested helper methods:

* `Bottle#tasting_notes_for_same_vintage`
* `Bottle#tasted?`
* `Vintage#tasting_notes_for_wine`
* `Vintage#tasted?`
* `Wine#tasting_notes_for_wine`
* `Wine#tasted?`

Names may differ if a clearer local convention already exists.

Avoid N+1 queries on index pages. Use aggregate queries, preloaded IDs, or other efficient Rails patterns to compute the
`Tasted` column.

## Tests

Add or update tests for:

* Bottle show page includes tasting notes for the current bottle.
* Bottle show page includes tasting notes for other bottles of the same vintage.
* Bottle show page includes tasting notes attached directly to the same vintage.
* Bottle show page does not include tasting notes from a different vintage.
* Vintage show page includes tasting notes across all vintages of the same wine.
* Wine show page includes tasting notes across all vintages of the same wine.
* Wine and vintage tasting note tables are sorted by vintage descending and tasting note date descending.
* Wine index `Tasted` column shows a green checkmark when the wine has any related tasting note.
* Vintage index `Tasted` column shows a green checkmark when the vintage has any related tasting note.
* Bottle index `Tasted` column shows a green checkmark only when that specific bottle has a tasting note.
* Index rows without related tasting notes leave the `Tasted` column blank.
