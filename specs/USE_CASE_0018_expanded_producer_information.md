# Expanded Producer Information

This use case expands the information stored and displayed for producers, and makes it easier to create a wine club record from a producer page.

## Producer Attributes

Add three new attributes to producers:

| Name         | Data type | Description                                      | Constraints |
|--------------|-----------|--------------------------------------------------|-------------|
| notes        | text      | General free-form notes about the producer       |             |
| tasting_room | text      | Free-form notes about the producer tasting room  |             |
| club_options | text      | Free-form notes about producer wine club options |             |

All three attributes should accept large free text blocks.

Add database comments matching the descriptions above.

## Producer Forms

On the producer new and edit forms, add form fields for:

* Notes
* Tasting room
* Club options

Use multi-line text areas.

Do not show helper text for these fields unless separately requested.

## Producer Show Page

On the producer show page, display:

* Notes
* Tasting room
* Club options

Render multi-line text as readable paragraphs.

Leave blank values blank.

## Wine Clubs On Producer Pages

On the producer show page and producer edit page, display any wine clubs for that producer.

The wine club display should include both:

* current wine clubs
* inactive wine clubs

Use the existing wine club ownership/visibility rules so users only see wine clubs visible to them.

The display should be read-only from producer pages.

Include enough information to distinguish each club, such as:

* tier
* size
* schedule
* delivery method
* date joined
* date left
* member id

Use a compact table if there are one or more clubs.

If there are no wine clubs for the producer, leave the section empty or omit the table.

## Joined Club Button

On the producer show page, add a button labelled "Joined Club".

The button should go to the new wine club form.

The new wine club form should be preloaded with the current producer.

The existing wine club form should continue to support direct navigation without a preloaded producer.

## Tests

Build tests for:

* the producer migration adds `notes`, `tasting_room`, and `club_options`
* the producer form includes multi-line fields for the three new attributes
* producer create/update permits and saves the three new attributes
* the producer show page displays the three new attributes
* blank producer text attributes render as blank, not placeholder text
* the producer show page lists current wine clubs for that producer
* the producer show page lists inactive wine clubs for that producer
* the producer edit page lists current and inactive wine clubs for that producer
* wine clubs not visible to the current user are not listed
* the producer show page includes a "Joined Club" button
* the "Joined Club" button links to the new wine club form with the producer preloaded
* the wine club new form preloads the producer when a `producer_id` parameter is provided

Run the relevant Rails tests after implementation.
