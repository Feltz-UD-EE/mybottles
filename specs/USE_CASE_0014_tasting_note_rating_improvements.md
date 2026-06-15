# Tasting Note Rating Improvements

## Overview

Add a new structured rating attribute to tasting notes and display that rating visually across tasting note, wine, and
vintage pages.

This use case intentionally does not remove or change the existing tasting note numeric score/rating value. The existing
attribute should remain in place because it will be removed in a future use case.

## Data Model

## Tasting Note

Add a new rating attribute to `TastingNote`.

| Name   | Data type | Relationships | Description                                  | Constraints                                           | Notes |
|--------|-----------|---------------|----------------------------------------------|-------------------------------------------------------|-------|
| rating | decimal   |               | Structured personal rating from zero to five | not null, values from 0 to 5 in 0.25-point increments |       |

### Constraints

The new `rating` attribute must:

* be not null
* allow values from `0` through `5`
* allow quarter-point increments only
* reject values outside the range
* reject values that are not exact 0.25 increments

Valid examples:

* `0`
* `0.25`
* `0.5`
* `1`
* `1.25`
* `2.5`
* `4.75`
* `5`

Invalid examples:

* blank
* `-0.25`
* `5.25`
* `3.1`
* `4.33`

Enforce this in both Rails validations and PostgreSQL constraints.

## Existing Score/Rating Value

Do not change the existing tasting note score/rating attribute in this use case.

Do not migrate, remove, rename, hide in historical views, or otherwise alter the existing value except where the UI
requirements below specify that only the new `rating` attribute should appear in create/edit forms.

## Forms

When creating or editing a tasting note, show only the new `rating` attribute for rating input.

Do not show the existing score/rating input in the create or edit form.

Use a sliding scale widget for the new rating input.

The slider should:

* have minimum value `0`
* have maximum value `5`
* move in `0.25` increments
* display the selected numeric value near the slider so the user can see the exact chosen value

If JavaScript is used to keep the displayed value in sync with the slider, it should follow the existing Stimulus
controller pattern in the project.

## Tasting Note Show Page

When showing a tasting note, display the new rating using a five-circle visual element.

Requirements:

* Always show all 5 circles.
* Empty circles should have a white background and a thin black outline.
* Filled portions should be green.
* Partial values should partially fill the appropriate circle.
* Quarter values should be visually represented, not rounded to whole circles.
* Hovering over the visual element should show the numeric rating value.

Examples:

* `0` shows five empty circles.
* `0.25` shows one quarter of the first circle filled.
* `2.5` shows two full circles, one half-filled circle, and two empty circles.
* `5` shows five full circles.

## Wine Show Page

At the top of the wine show page, display the average of the new `rating` value for all tasting notes for that wine.

Use the same relationship scope implemented for extended tasting notes:

* tasting notes attached to any bottle belonging to any vintage of that wine
* tasting notes attached directly to any vintage of that wine

Use the same five-circle visual element as the tasting note show page.

Display rules:

* The visual element should show the average value rounded for visual display in a reasonable way compatible with the
  partial-circle graphic.
* Hovering over the visual element should show the actual unrounded average value with two digits of precision.
* If there are no tasting notes with a rating, leave the rating area blank or show the project-standard empty state.

## Vintage Show Page

At the top of the vintage show page, display the average of the new `rating` value for tasting notes in the same scope
used by the vintage show page's extended tasting note table.

That means the average should include all tasting notes for the vintage's wine, regardless of vintage, because the
vintage page is intentionally used for comparing a wine across vintages.

Use the same five-circle visual element as the tasting note show page.

Display rules:

* The visual element should show the average value rounded for visual display in a reasonable way compatible with the
  partial-circle graphic.
* Hovering over the visual element should show the actual unrounded average value with two digits of precision.
* If there are no tasting notes with a rating, leave the rating area blank or show the project-standard empty state.

## Visual Rating Element

Create a reusable view helper or partial for the rating-circle display.

The helper or partial should accept:

* the rating value
* optional hover/title text
* optional accessible label

Accessibility requirements:

* The visual element should have an accessible label that includes the numeric rating.
* Hover text should expose the numeric value.
* The circles should not rely on color alone for meaning; the accessible label is required.

Implementation guidance:

* Prefer CSS for the circle and partial-fill rendering.
* Do not introduce a new icon library for this feature.
* Keep the visual element compact enough to fit near page titles and in detail rows.

## Tests

Add or update tests for:

* `TastingNote` requires the new `rating` attribute.
* `TastingNote` accepts values from `0` through `5` in 0.25 increments.
* `TastingNote` rejects values outside the range.
* `TastingNote` rejects values that are not exact 0.25 increments.
* The database rejects invalid `rating` values.
* Tasting note new/edit forms show the new slider input.
* Tasting note new/edit forms do not show the existing score/rating input.
* Tasting note show page displays the five-circle rating element.
* The rating element represents partial-circle values.
* Wine show page displays the average rating for related tasting notes.
* Vintage show page displays the average rating for the same wine-wide tasting note scope used by extended tasting notes.
* Wine and vintage average rating hover text shows the unrounded average with two digits of precision.
