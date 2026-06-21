# Producer Wine Creation

When creating or editing a producer, it should be easier for the user to create wines for that producer at the same time.

Producers, wines, and vintages are community-curated canonical data. This use case must preserve the existing community-curation and trust/review behavior for each object type.

## Producer Form

On both the new producer form and the edit producer form, add a section at the bottom of the page for creating wines belonging to that producer.

This section should appear after the normal producer fields and before the save button.

The section should include:

* a list of existing wines for that producer
* a single subform for entering a new wine
* a button labelled "Add another wine"

Existing wines should be displayed as read-only information. They should not be editable from this section.

For a new producer, there will be no existing wines yet, so the existing-wines list may be empty.

## Wine Subforms

Each wine subform should collect the normal wine attributes needed for creating a wine belonging to the producer.

The wine subform should not include a producer selector, because the producer is already established by the parent producer form.

Each wine subform should also include a form element for `vintage`.

If the user clicks "Add another wine", display another blank wine subform.

The first blank wine subform should be visible by default.

Do not create a wine from a completely blank wine subform.

If any field in a wine subform is completed, then that wine subform should be treated as an attempted wine creation and should be validated normally.

## Saving Behavior

When saving a new producer or an edited producer, perform a cascade of object creation:

1. save the producer
2. create and save each new wine from a non-blank wine subform
3. for each created wine, if there is a value in that subform's `vintage` field, create and save a vintage belonging to that wine
4. for each created wine, if the `vintage` field is blank, do not create a vintage

Use a database transaction for the direct save operation so that failed validation does not leave a partial direct-save set of producer, wines, and vintages.

For users whose canonical-data changes require review, the implementation must follow the existing community-curated pending-record/shadow-record behavior rather than bypassing review. If the existing architecture requires pending producer/wine/vintage records instead of direct canonical records, apply the same cascade semantics to those pending records.

## Editing Existing Producers

When editing an existing producer:

* display the producer's existing wines as read-only
* allow the user to add one or more new wines
* do not modify existing wines from this section
* if the producer edit itself becomes a pending proposed change under the trust/review workflow, the newly submitted wines and vintages should still be handled consistently with community-curated data rules

## Confirmation Message

After saving successfully, the confirmation message should state how many different wines were created.

Examples:

* "Producer was successfully created. 0 wines were created."
* "Producer was successfully created. 1 wine was created."
* "Producer was successfully updated. 3 wines were created."

Use "wine" for one and "wines" for all other counts.

If the trust/review workflow changes the final wording because records are pending review, the message should still include the number of submitted wines.

## Tests

Build tests for:

* the new producer form shows the wine creation section
* the edit producer form shows the wine creation section
* the edit producer form lists existing wines for that producer as read-only
* the wine subform does not include a producer selector
* the first blank wine subform is visible by default
* the "Add another wine" button adds another blank wine subform
* completely blank wine subforms do not create wines
* saving a new producer with one wine subform creates the producer and wine
* saving a new producer with multiple wine subforms creates the producer and all submitted wines
* saving a producer with a wine subform and vintage value creates the wine and vintage
* saving a producer with a wine subform and blank vintage value creates the wine and no vintage
* saving an existing producer with new wine subforms creates the new wines for that producer
* validation failures do not persist a partial direct-save set
* the confirmation message includes the number of wines created or submitted
* community-curated review behavior is preserved for producer, wine, and vintage creation

Run the relevant Rails tests after implementation.
