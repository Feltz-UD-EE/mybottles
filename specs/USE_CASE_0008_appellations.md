# Appellations

I want to create the core tables and CRUD actions/views for the geographic elements of wine making - appellations. See
the [Wikipedia article](https://en.wikipedia.org/wiki/Appellation) referenced elsewhere.

The object types below will include a description that you should read for context and for future development.

All tables should be created so that the auto-generated id column is a UUID.

All tables should include standard created_at and updated_at columns.

All other columns will be specified with name, data type, relationships, a description, and constraints, etc. I will
also note where I anticipate that a column will eventually be changed from a simple text entry to a normalized object relationship.

Table and column descriptions, where possible, should be inserted as metadata to the Postgres schema.

# Models

## Country

Countries are just what they say they are - the top political bodies.

| Name     | Data type | Relationships | Description                            | Constraints | Notes |
|----------|-----------|---------------|----------------------------------------|-------------|-------| 
| name     | text      |               | The common name for the country        | not null    |       | 
| fullname | text      |               | The full legal name of the country     |             |       | 
| iso2     | text      |               | The ISO-2 country code for the country | not null    |       | 
| iso3     | text      |               | The ISO-3 country code for the country | not null    |       | 
| notes    | text      |               | Other descriptive notes                |             |       | 

### Special UI considerations

In the main menu, create a new item "Geography", with subitems "Countries" and "Regions"

On the country index page, show the total number of appellations with the label "Named regions:" (as defined by the appellations object below).

On the country show page, show a compact table of all appellations in that country.

## Appellations

An appellation is a legally defined, named region for wine production.  The appellation system for wines was first pioneered in France. All wines either 
have an appellation, or as a default, a country. Appellations are often nested within each other.

| Name           | Data type | Relationships                      | Description                                                          | Constraints | Notes                                                                                                |
|----------------|-----------|------------------------------------|----------------------------------------------------------------------|-------------|------------------------------------------------------------------------------------------------------| 
| country_id     | UUID      | appellation belongs to country     | What country the appellation is in                                   | Not null    |                                                                                                      |
| name           | text      |                                    | The nametag or other label applied to the bin                        | not null    |                                                                                                      |
| degree         | text      |                                    | The legal category of appellations - many countries have two or more |             | Eventually this will become an enum validation specific to each country                              | 
| parent_id      | UUID      | appellation belongs to appellation | The parent appellation, if present                                   |             | Self-referential tree structure, unlimited depth                                                     | 
| notes          | text      |                                    | Any other descriptive information about the appellation              |             |                                                                                                      |
| auto-generated | boolean   |                                    | Whether the information for this appellation was LLM-generated       |             | This field will eventually be deprecated, after this information has been manually vetted and edited |

Although I use the term "appellations" in this document and for the object definition, use the word "Region" for display purposes and for the Rails routes, as it is more generic and more understandable to the average wine buyer. 
Include an appropriate comment in the routes file, the model and controller files, etc.

### Special UI Considerations

On the appellation show page, include a compact table showing all the child appellations - nest this if necessary with weak indenting.  For example
Côtes-du-Rhône
  Côtes-du-Rhône Villages
    Gigondas
    Vacqueyras

On the country show page, include a link to a list of all appellations in that country (using the same layout as the appellations index page) 

# Update to existing elements

Do not make any updates to existing elements yet.  I first want to build out this structure before changing wines & vintages.

# Seeds

Generate seeds for both objects.

For country seeds, start with only the following significant wine producers - access standard reference sites for every field except notes:
USA, Canada, Argentina, Chile, Uruguay, South Africa, Australia, New Zealand, Portugal, Spain, France, Germany, Italy, Hungary, 
Austria, Romania, Moldova, Georgia, Israel

For appellation seeds, for each of the countries above, start with the referenced Wikipedia article and traverse to gather sufficient information.
Set the auto-generated field to TRUE. Do not use non-Latin alphabets. For the USA, make sure that all 50 states are included as top-level appellations.

After generating the seeds, stop so that I can give preliminary approval.