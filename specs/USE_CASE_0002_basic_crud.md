# Basic Crud

I want to create the core tables and CRUD actions/views for wines, along with some minimal seeds. For each of the 
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

## Producer

Producers are individual, co-ops, corporations, and other entities that make wine. They may or may not own land with grapes.
They may use their own grapes, purchased grapes, or a combination of the two. Producers typically, though not always, make
more than one wine.

| Name    | Data type | Relationships | Description                                | Constraints           | Notes                                                                       |
|---------|-----------|---------------|--------------------------------------------|-----------------------|-----------------------------------------------------------------------------| 
| name    | text      |               | The legal trade name of the producer       | not null              |                                                                             | 
| address | text      |               | The mailing address of the producer        |                       | Generalized because of varying international address standards              | 
| email   | text      |               | The contact email address of the producer  | valid email format    |                                                                             | 
| website | text      |               | The public website address of the producer | valid HTTP URL format |                                                                             |
| phone   | text      |               | The contact phone number of the producer   |                       | Generalized because of varying international phone number formatting styles | 

## Wine

Wines are named wine brands. A wine belongs to a producer.  

| Name        | Data type | Relationships            | Description                                             | Constraints                                    | Notes                                                                                                                              |
|-------------|-----------|--------------------------|---------------------------------------------------------|------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| name        | text      |                          | The legal trade name of the wine                        | not null                                       |                                                                                                                                    |
| description | text      |                          | A description of the wine                               |                                                |                                                                                                                                    |
| producer_id | UUID      | wine belongs to producer | The producer of the wine                                | not null                                       | Wines never change producers                                                                                                       |
| style       | text      |                          | The type of wine: still, sparkling, fortified, flavored | ENUM limited to the 4 types in the description |                                                                                                                                    |
| color       | text      |                          | The color of wine: red, white, rosé, orange             | ENUM limited to the 4 types in the description |                                                                                                                                    |
| appellation | text      |                          | The wine-growing region of the wine                     |                                                | This will eventually change to a reference to a separate appellations model. Appellations are defined by law in various countries. |

## Vintage

Vintages are individual 'editions' of a wine. Vintages are usually named after the year that the grapes are harvested.
Because producers sometimes blend across year boundaries, some vintages are edition names or numbers, or are just labelled as 
"non-vintage".

| Name    | Data type | Relationships           | Description                    | Constraints                                                                              | Notes |
|---------|-----------|-------------------------|--------------------------------|------------------------------------------------------------------------------------------|-------|
| vintage | text      |                         | The vintage labelled           | not null                                                                                 |       |
| wine_id | UUID      | vintage belongs to wine | The wine                       | not null                                                                                 |       |
| grapes  | text      |                         | The list of grapes in the wine | This will eventually change to a join table listing vintages and grapes with percentages |

## Bottle

Bottles are individual units of sales of a wine. People purchase and store bottles, often times multiple bottles of a given vintage.

| Name               | Data type | Relationships             | Description                                                                  | Constraints                                           | Notes                                                                                     |
|--------------------|-----------|---------------------------|------------------------------------------------------------------------------|-------------------------------------------------------|-------------------------------------------------------------------------------------------|
| personal_inventory | text      |                           | An individual numbering code, often for legacy purposes                      |                                                       | This will eventually have constraints                                                     |
| vintage_id         | UUID      | bottle belongs to vintage | The vintage                                                                  | not null                                              |                                                                                           |
| purchase_date      | date      |                           | The date the bottle was purchased or otherwise acquired                      |                                                       |                                                                                           |
| purchase_source    | text      |                           | The retailer or other location that the bottle was purchased from            |                                                       |                                                                                           |
| list_price         | decimal   |                           | The list price of the bottle at time of purchase                             | USD currency                                          |                                                                                           |
| discount_price     | decimal   |                           | The discounted price of the bottle                                           | USD currency                                          | Discounts can happen due to volume purchases, membership in a wine club, or other reasons |
| notes              | text      |                           | Any notes about the bottle or the purchase experience                        |                                                       |                                                                                           |
| disposal_date      | date      |                           | The date the bottle was consumed, given away, sold, or otherwise disposed of | Must be after purchase_date (if purchase date exists) |                                                                                           |
| disposal_method    | text      |                           | The way in which the bottle was disposed: drink, gift, sale, or spoiled      | not null, ENUM to the 4 listed values                 |                                                                                           |

Create a helper method in_inventory? on the model - if disposal_date is NIL, then in_inventory? is true

# Seeds

Build an initial seeds file from this [Google Sheet](https://docs.google.com/spreadsheets/d/1lPUTOZjWJbnqO_AGktr04ppRzjUZISxspiTCgLuROt0/edit?usp=sharing), 
tab "Michigan 2026" only, using the following rules:
* This spreadsheet is denormalized, you will need to extract different fields into different Rails models and then link them appropriately.
* The brand column is the producer name; leave other producer fields blank
* The variety/name column is the wine name and the region column is the wine appellation; leave other wine fields blank
* The vintage column is the vintage; leave other vintage fields blanks
* Concatenate the first two columns with a dash, and left-pad the second column to 3 digits, to create the personal_inventory field for a bottle - eg M26-001
* The retailer column is the purchase source for a bottle, the Purch Date column is the purchase_date for a bottle.
* The notes field are notes for the bottle table
* Extract the date from the Tasted column and use it as the disposal_date; if the date is only listed as a year and month, then set the day for the disposal date to be the 15th of that month & year.

Let me manually examine this seeds file before attempting to use it.
