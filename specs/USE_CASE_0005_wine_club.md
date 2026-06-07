# Wine Clubs

I want to create the core tables and CRUD actions/views for wine clubs. For each of the 
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

## Wine_club

Wine clubs are subscription memberships offered by wineries that include such features as discounts, free or reduced shipping,
access to special wines, preferential treatment at the producer's tasting rooms, invitations to special events, etc. A given
producer will typically offer several wine club tiers.

| Name            | Data type | Relationships                 | Description                                                                | Constraints                | Notes                                                                           |
|-----------------|-----------|-------------------------------|----------------------------------------------------------------------------|----------------------------|---------------------------------------------------------------------------------| 
| producer_id     | UUID      | wine club belongs to producer | The producer offering the wine club                                        | not null                   |                                                                                 | 
| tier            | text      |                               | The tier title of the club membership - like gold, reserve, etc.           |                            |                                                                                 | 
| size            | integer   |                               | The number of bottles in each club order                                   | not null                   |                                                                                 | 
| schedule        | text      |                               | How often and when wine is delivered                                       | not null                   |                                                                                 |
| delivery_method | text      |                               | Whether the wine is shipped or held for pickup                             | ENUM = shipping, pickup    |                                                                                 | 
| payment_method  | text      |                               | How the club membership is paid for (typically a pre-approved credit card) |                            |                                                                                 | 
| discount        | decimal   |                               | What discount the club order is processed at relative to list price        | percentage from 0% to 100% |                                                                                 | 
| date_joined     | date      |                               | When I joined the wine club                                                |                            |                                                                                 | 
| date_left       | date      |                               | When I cancelled my wine club membership                                   |                            | Create a helper method on the model current_member?; true if this field is null | 
| member_id       | text      |                               | An ID supplied by the producer                                             |                            |                                                                                 | 
| benefits        | text      |                               | Any other benefits accruing to club members                                |                            |                                                                                 | 

### Special UI considerations

In the main menu, create a new item "Clubs", with 3 subitems:
* Current: goes to a club index page, only for clubs where current_member? is true
* All: goes to a club index page with all clubs
* New: goes to a new club form

On the new club form, have a button next to the Producer dropdown labelled "New Producer" that launches a compact form for 
creating a new producer, which appropriately sequences saving the producer object and the wine club object, appropriately linked.