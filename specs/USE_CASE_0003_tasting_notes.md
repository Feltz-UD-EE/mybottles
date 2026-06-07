# Basic Crud

I want to create the core tables and CRUD actions/views for tasting notes. For each of the 
object types described below, create:
* the model file and migration file
* the controller/view scaffolding for all CRUD actions
* an index page listing all entries, using a dynamic table UI element
* a top-level menu entry that leads to the index page

The object types below will include a description that you should read for context and for future development.

All tables should be created so that the auto-generated id column is a UUID.

All tables should include standard created_at and updated_at columns.

All other columns will be specified with name, data type, relationships, a description, and constraints, etc. I will
also note where I anticipate that a column will eventually be changed from a simple text entry to a normalized object relationship.

Table and column descriptions, where possible, should be inserted as metadata to the Postgres schema.

# Models

## TastingNote

Tasting Notes are personal notes about tasting wine - from a particular bottle, or from a representative wine & vintage 
at a winery or retailer. 

Tasting notes will have a polymorphic relationship, `tasteable`, so that they can belong to either a bottle or a vintage.

| Name        | Data type | Relationships | Description                                                                     | Constraints                     | Notes                                                            |
|-------------|-----------|---------------|---------------------------------------------------------------------------------|---------------------------------|------------------------------------------------------------------| 
| date        | date      |               | The date the tasting took place                                                 | not nil                         |                                                                  | 
| setting     | text      |               | The setting where the tasting took place                                        |                                 | This may eventually become a reference to producer or a retailer | 
| temperature | text      |               | The temperature of the wine                                                     |                                 |                                                                  | 
| pairing     | text      |               | Any accompanying food                                                           |                                 |                                                                  | 
| color       | text      |               | The color of the wine                                                           |                                 |                                                                  |
| nose        | text      |               | The aromatic elements of the wine                                               |                                 |                                                                  | 
| palate      | text      |               | The taste elements of the wine                                                  |                                 |                                                                  | 
| overall     | text      |               | The overall impression of the wine                                              |                                 |                                                                  |
| score       | decimal   |               | The contact phone number of the producer                                        | 1 digit after the decimal point |                                                                  |
| buy         | boolean   |               | Should I buy this wine (or buy it again if the tasting note refers to a bottle) | not nil                         | Default = false                                                  | 

Also add the tasteable_type and tasteable_id columns in appropriate Rails polymorphic form 

### Special UI considerations

Add a link from the bottle show page to a new tasting note form, using a button labelled "Tasted This". This should pre-load
the bottle information into the appropriate visible and hidden form elements.  When a tasting note created from this path is saved, 
it should also update the bottle so that the disposal date is equal to the tasting note date, and the disposal method is set to 'drink'.

Add a link on the home page to a new tasting note form, using a button labelled "Let's Taste!". This should show a version of the
form with a type-ahead box to find a vintage.  There should be a button on the side of that type-ahead box "New wine" which leads to a compact
form for creating producer + wine + vintage using the same inheritance logic you've already built for generating wine/producer/vintage seeds.  
Everything up to and including the tasting note should be saved together and appropriately linked.

There should be two save buttons at the bottom of this form:
* "Done Tasting" saves this form and returns the user to the home page
* "Taste Another" saves this form and shows another tasting note form, with date and setting pre-loaded.

# Seeds

Build seeds for tasting notes from this [Google Sheet](https://docs.google.com/spreadsheets/d/1lPUTOZjWJbnqO_AGktr04ppRzjUZISxspiTCgLuROt0/edit?usp=sharing), 
tabs labelled "Retail YYYY" or "Michigan YYYY" only, using the following rules:
* Extract the text from the Tasting column and put it in the overall attribute.
* If there is anything in the Tasting column about purchasing the wine again, set 
* If there is any text in the tasting column that is specifically about color or aroma, extract that information and 
place it in the color or nose attributes.

Let me manually examine this seeds file before attempting to use it.
