# Watch list

I want to create the core tables and CRUD actions/views for my watch list. For each of the 
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

## Watch_list_entries

Watch list entries are vintages, wines, or general information about wines I want to purchase in the future.

Watch list entries will have a polymorphic relationship, `watchable`, so that they can belong to either a vintage or a wine; this
relationship should also allow nulls, so that only the free text elements of the watch_list_entry are used.


| Name        | Data type | Relationships | Description                                                                                            | Constraints | Notes |
|-------------|-----------|---------------|--------------------------------------------------------------------------------------------------------|-------------|-------| 
| description | text      |               | The motivation or justification for looking for this wine                                              | not null    |       | 
| quantity    | text      |               | How much to purchase                                                                                   |             |       | 
| caveat      | text      |               | Description of why not to buy the wine if it is available - too expensive, bad vintage, etc.           |             |       | 
| notes       | text      |               | Any additional information about this entry, including exclusive retailers, date of availability, etc. |             |       | 

Also add the watchable_type and watchable_id columns in appropriate Rails polymorphic form.

Watch list entries should be soft-deletable; use a standard Rails feature to implement this.

### Special UI Considerations

The main menu item should be titled "Watch List" and should lead to an index page with all watch list items that are not deleted. 

There should be a dynamic element on the table, labelled "remove" in the rightmost column, that makes a watch list entry soft-deleted.

There should be a button at the bottom of the index page labelled "Old Entries" that goes to an index page with only the soft-deleted
watch list entries. This version of the index page should have a dynamic element on the table, labelled "restore" in the rightmost column, 
that makes a watch list entry un-deleted.

On the existing wine, vintage, and bottle show pages and index pages, there should be a button labelled "Add to Watch List"; which leads to the new
watch list entry form page, preloaded with watchable_type = wine if from the wine page, and with watchable_type = vintage if from the vintage or
bottle page.
