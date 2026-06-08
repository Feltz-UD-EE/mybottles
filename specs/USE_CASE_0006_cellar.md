# Cellar

I want to create the core tables and CRUD actions/views for cellars. For each of the 
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

## Cellar

Cellars are places to store wine.  A user may have one or more cellars.  Cellars have a variety of sub-elements - bays, bins, shelves.  "Cellar" is also a way to describe other kinds of storage systems and locations, such as wine refrigerators.

| Name     | Data type | Relationships | Description                                        | Constraints | Notes |
|----------|-----------|---------------|----------------------------------------------------|-------------|-------| 
| name     | text      |               | A convenient name for a cellar                     | not null    |       | 
| location | text      |               | Where the cellar is located                        |             |       | 
| notes    | text      |               | Any other descriptive information about the cellar |             |       | 

### Special UI considerations

In the main menu, create a new item "Cellars", with subitems "Bins" "Bays" and "Shelves"

On the cellar show page, add buttons "New Bin", "New Bay", "New Shelf" that lead to appropriate forms for the models being defined below.

On the cellar show and index pages, add fields to display the total number of bottles currently stored in each cellar, using the relationships defined below 
and taking into account nesting.

## Bin

A bin is a large, unstructured storage element within a cellar.  A bin is typically, though not always, used to store multiple bottles of the same vintage.

Do not confuse this use of the word "bin" with the use of "Bin" within a wine name. "Bin" in a wine name is often used in Australia for branding wine with
a particular blend, a particular source region or vineyard, etc. For example - "Lindeman's Bin 45 Cabernet-Merlot", where the producer name is Lindeman's. 
The two senses of the word bin have the same etymology.

| Name      | Data type | Relationships         | Description                                     | Constraints | Notes           |
|-----------|-----------|-----------------------|-------------------------------------------------|-------------|-----------------| 
| cellar_id | UUID      | bin belongs to cellar | What cellar the bin is located in               | Not null    |                 |
| label     | text      |                       | The nametag or other label applied to the bin   |             |                 |
| location  | text      |                       | Where the bin is located within the cellar      |             | Eg "north wall" | 
| notes     | text      |                       | Any other descriptive information about the bin |             |                 |

### Special UI Considerations

On the bin show and index pages, add fields to display the total number of bottles currently stored in each bin.

## Bay

A bay is a section of a cellar.  Bays are composed of racks of shelves.

| Name      | Data type | Relationships         | Description                                     | Constraints | Notes           |
|-----------|-----------|-----------------------|-------------------------------------------------|-------------|-----------------| 
| cellar_id | UUID      | bay belongs to cellar | What cellar the bay is located in               | Not null    |                 |
| label     | text      |                       | The nametag or other label applied to the bay   |             |                 |
| location  | text      |                       | Where the bay is located within the cellar      |             | Eg "north wall" | 
| notes     | text      |                       | Any other descriptive information about the bay |             |                 |

### Special UI considerations

On the bay show page, add a button "New Shelf" that leads to the appropriate form for the model being defined below.

On the bay show and index pages, add fields to display the total number of bottles currently stored in each bay, using the relationship defined below
and taking into account nesting.

## Shelf

A shelf is a horizontal surface or rack suitable for placing bottles. Shelves often have small separators so that bottles are not touching
each other and can be drawn out easily.  Shelves may be one bottle deep or sometimes multiple bottles deep.

Shelves will have a polymorphic relationship, `shelveable`, so that they can belong to either a cellar or a bay.  Nulls are not allowed.

| Name   | Data type | Relationships         | Description                                                           | Constraints            | Notes                |
|--------|-----------|-----------------------|-----------------------------------------------------------------------|------------------------|----------------------| 
| number | text      |                       | A numeric or semi-numeric label for the shelf for sorting purposes    |                        | Eg "1" or "2A"       |
| label  | text      |                       | Any label that might be applied to a shelf; this may change over time |                        | Eg "Bordeaux to age" |
| depth  | text      |                       | Whether the shelf is a single bottle deep or multiple                 | ENUM: Single, Multiple | default value single | 
| notes  | text      |                       | Any other descriptive information about the shelf                     |                        | EG sized for magnums |

Also add the shelveable_type and shelveable_id columns in appropriate Rails polymorphic form.

The default sort order for all sets of shelves is by number, ascending.

### Special UI considerations

On the shelf show and index pages, add fields to display the total number of bottles currently stored in each shelf.

# Update to existing elements

Add a polymorphic relationship "cellarable" to bottles.  A bottle may belong to a cellar, a bin, or a shelf, or it may have a null entry for cellarable. 
All existing bottles should default to null.

On the bottle show page and index page, indicate where the bottle is cellared using the label "Location". 
Create helper methods for the Location text to handle the following examples: 
* a bottle on shelf number = "5" of bay label = "North" in cellar name = "Beach House" is displayed Location: "Beach House - North 5"
* a bottle in bin label = "Everyday Spanish" in cellar name = "Main" is displayed Location: "Main - Everyday Spanish"
* a bottle on shelf number "2" of cellar name = "Fridge 1" is displayed Location: "Fridge 1 - Shelf 2"
* a bottle in cellar name = "Bar Fridge" is displayed Location: "Bar Fridge"
* a bottle where cellarable is null is displayed Location: "Not Cellared"

On the bottle form, add a dropdown that includes, in this order:
* a placeholder null value "Not Cellared"
* all cellars, sorted alphabetically
* all bins, sorted alphabetically by cellar
* all shelves, sorted alphabetically by cellar, bay (if applicable), and shelf.

Use that dropdown to populate the cellarable polymorphic columns for a bottle.