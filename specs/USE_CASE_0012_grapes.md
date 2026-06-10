# Grapes

## Overview

Create basic CRUD for wine-making grapes, grape synonym relationships, and appellation-grape permissions.

There are approximately 1,500 significant wine-making grapes in the world. This use case creates the canonical data
structure needed to store those grapes, relate known synonyms, and record which grapes are permitted in specific
appellations.

All tables should be created so that the auto-generated id column is a UUID.

All tables should include standard created_at and updated_at columns.

Table and column descriptions, where possible, should be inserted as metadata to the Postgres schema.

All three data types in this use case are community-curated canonical data. They should use the trust, shadow-record,
approval, proposed-change, review queue, PaperTrail, and public_activity behavior implemented in use cases 0009, 0010,
and 0011.

## Data Bucket

The following models are community-curated canonical data:

* Grapes
* Grape Synonyms
* Appellation Grapes

Policy:

* Approved canonical records are visible to appropriate public and signed-in users.
* Basic and Trusted users may submit new records and edits for review.
* Basic and Trusted edits to approved canonical records must not overwrite canonical data before review.
* Curator and System Administrator users may review pending creates and edits.
* Curator and System Administrator-created records may be created as Approved immediately.
* Pending rows should be visible only to the submitting user, Curators, and System Administrators.
* Rejected rows should be visible only to the submitting user, Curators, and System Administrators.
* Merged rows should be visible to Curators and System Administrators.

Use the same approval columns and status values already used for community-curated canonical data:

| Name                | Data type | Relationships                    | Description                                     | Constraints                                         | Notes                                 |
|---------------------|-----------|----------------------------------|-------------------------------------------------|-----------------------------------------------------|---------------------------------------|
| approval_status     | text      |                                  | Review status for this record                   | not null, enum: Pending, Approved, Rejected, Merged | Default Pending for low-trust creates |
| created_by_user_id  | UUID      | user belongs to user             | User who first created this record              |                                                     |                                       |
| approved_by_user_id | UUID      | user belongs to user             | User who approved this record                   |                                                     |                                       |
| approved_at         | datetime  |                                  | When this record was approved                   |                                                     |                                       |
| rejected_by_user_id | UUID      | user belongs to user             | User who rejected this record                   |                                                     |                                       |
| rejected_at         | datetime  |                                  | When this record was rejected                   |                                                     |                                       |
| merged_into_id      | UUID      | same model belongs to same model | Canonical record this duplicate was merged into |                                                     | Self-reference                        |

## Models

## Grape

Grapes are botanical wine-making grape varieties or recognized wine-making grape cultivars.

The `name` column is not unique. Some grapes have the same common English name but refer to totally different grapes.

| Name  | Data type | Relationships | Description                          | Constraints | Notes      |
|-------|-----------|---------------|--------------------------------------|-------------|------------|
| name  | text      |               | The common display name of the grape | not null    | Not unique |
| notes | text      |               | Notes about the grape                |             |            |

### Relationships

* A grape has many grape synonym relationships as either side of the synonym pair.
* A grape has many synonym grapes through grape synonym relationships.
* A grape has many appellation grape records.
* A grape has many appellations through appellation grape records.

### Display

Use the grape `name` as the default display name.

If disambiguation is needed because more than one grape has the same name, include enough contextual information from
`notes` or related records to help reviewers choose the correct grape. Do not create an artificial uniqueness suffix in
the `name` column.

## Grape Synonym

Grape synonyms record that two grape records are known synonyms. The best-known example is Syrah and Shiraz.

There is no significance to which grape is the first referential entry and which is second.

Although most synonym relationships involve a simple pair, a grape can have multiple synonyms. Implement this as a graph
of unordered pair relationships between grape rows. Do not attempt to force all synonyms into one canonical synonym group
in this use case.

| Name             | Data type | Relationships                  | Description                          | Constraints | Notes                    |
|------------------|-----------|--------------------------------|--------------------------------------|-------------|--------------------------|
| grape_id         | UUID      | grape_synonym belongs to grape | One grape in the synonym pair        | not null    | No ordering significance |
| synonym_grape_id | UUID      | grape_synonym belongs to grape | The other grape in the synonym pair  | not null    | No ordering significance |
| notes            | text      |                                | Notes about the synonym relationship |             |                          |

### Least-Risky Relationship Implementation

Because the synonym relationship is unordered, use database constraints to prevent accidental duplicate inverse rows.

Required constraints:

* `grape_id` must be different from `synonym_grape_id`.
* The unordered pair must be unique. A row for Syrah-Shiraz should prevent a second Shiraz-Syrah row.

Recommended Postgres implementation:

* Store the two explicit references as `grape_id` and `synonym_grape_id`.
* Add a unique expression index on `LEAST(grape_id, synonym_grape_id)` and `GREATEST(grape_id, synonym_grape_id)`.
* Add a model validation that checks the same unordered uniqueness rule for friendly Rails error messages.

This allows any grape to have multiple synonym edges while preventing duplicate edges between the same two grapes.

### Relationships

* A grape synonym belongs to grape.
* A grape synonym belongs to synonym grape, class name `Grape`.

## Appellation Grape

Appellation grapes record grapes that are permitted in an appellation.

Many appellations, especially in Europe, have a restricted list of grapes permitted to be made into wine in that
appellation. Every appellation can have one or more grapes, and every grape can have many appellations.

Some appellations have no grape restrictions. Those appellations should have no entries in this join table.

| Name           | Data type | Relationships                            | Description                                   | Constraints | Notes |
|----------------|-----------|------------------------------------------|-----------------------------------------------|-------------|-------|
| appellation_id | UUID      | appellation_grape belongs to appellation | The appellation where this grape is permitted | not null    |       |
| grape_id       | UUID      | appellation_grape belongs to grape       | The permitted grape                           | not null    |       |
| notes          | text      |                                          | Notes about this grape in this appellation    |             |       |

### Constraints

* The pair of `appellation_id` and `grape_id` should be unique among non-merged approved/pending records.
* If the same grape is submitted twice for the same appellation, Curators and System Administrators should resolve the
  duplicate through the review workflow instead of creating duplicate canonical rows.

### Relationships

* An appellation grape belongs to an appellation.
* An appellation grape belongs to a grape.
* An appellation has many appellation grapes.
* An appellation has many grapes through appellation grapes.
* A grape has many appellation grapes.
* A grape has many appellations through appellation grapes.

## UI

## Navigation

Create a new top-level menu item labelled `Grapes`.

The menu item should go to the grape index page.

## Grape Index Page

Create a sorted alphabetical list of grapes.

Use the existing dynamic table pattern.

Show at least:

| column_name  | Description                                                                              |
|--------------|------------------------------------------------------------------------------------------|
| name         | Grape name, linked to the grape show page                                                |
| synonyms     | Count or compact display of synonyms                                                     |
| appellations | Count of appellations that allow this grape, including appellations that allow a synonym |

Display community-curation status tags where appropriate.

## Grape Show Page

Display:

* Grape name.
* Notes.
* Community-curation status tag where appropriate.
* All synonyms of the grape.
* All appellations that allow this grape directly.
* All appellations that allow a synonym of this grape.

The appellation list should make clear whether the permission is direct or through a synonym.

If an appellation appears both directly and through a synonym, show it only once and prefer the direct relationship.

## Grape Forms

Create normal CRUD forms for grapes.

Do not require `name` to be unique.

Do not show field descriptions or helper text unless specifically requested.

## Grape Synonym UI

Provide a way to create, edit, and remove grape synonym relationships.

The UI should make clear that the relationship is unordered.

Use grape dropdown labels that are sufficiently descriptive to help avoid confusing two different grapes with the same
name.

## Appellation Show Page

On the appellation show page, display all grapes allowed for that appellation.

Show at least:

| column_name | Description                                |
|-------------|--------------------------------------------|
| grape       | Grape name, linked to the grape show page  |
| notes       | Notes about this grape in this appellation |

If the appellation has no grape restrictions, leave the table empty or show a concise empty state.

## Appellation Form

On the appellation form, create a dynamic element for appellation grapes.

The dynamic element should allow a user to:

* Add a grape to the appellation.
* Remove a grape from the appellation.
* Create or edit the `notes` field for each appellation-grape relationship.

Use existing Rails nested-attribute or equivalent form patterns where appropriate.

Respect community-curation rules:

* Curator and System Administrator changes may update approved canonical appellation-grape rows directly.
* Basic and Trusted user changes to approved canonical appellation-grape rows should create proposed changes.
* Basic and Trusted user additions should create pending shadow records visible to the submitting user and reviewers.

## Review Queue

Update the review queue to include:

* Pending Grapes.
* Pending Grape Synonyms.
* Pending Appellation Grapes.
* Proposed changes for Grapes, Grape Synonyms, and Appellation Grapes.

Review queue rows should use the same dense table pattern already defined for community-curated canonical data.

Duplicate merge behavior should be implemented where practical:

* Duplicate Grapes can be merged into a canonical Grape. Repoint grape synonyms and appellation grapes as needed.
* Duplicate Grape Synonyms should be merged or rejected so that one unordered synonym edge remains.
* Duplicate Appellation Grapes should be merged or rejected so that one appellation-grape permission remains.

Merge operations must be wrapped in a database transaction.

Never hard-delete merged community-curated records in this use case.

## Public Visibility

Approved grapes and their approved synonym/appellation relationships may be visible to public users where public pages
allow them.

Public users must not see pending, rejected, or merged grape-related rows.

If public grape pages are added in this use case, use separate public-facing controllers/actions/views as established in
use case 0009.

## Updates To Existing Models

Update Appellation so that it has many appellation grapes and many grapes through appellation grapes.

Do not change Wine or Vintage grape storage in this use case unless explicitly instructed later. The existing Vintage
`grapes` text field should remain in place for now.

## Seeds

Create seed files for grapes, but stop after creating the files so they can be manually reviewed before they are run.

Use public resources to gather wine-making grape names and known synonyms. Appropriate starting resources include:

* Wikipedia pages for wine grapes and grape variety lists.
* Vitis International Variety Catalogue, where publicly available.
* Regional or national wine authority pages for permitted grapes by appellation, where publicly available.
* Other public reference pages with clear wine-making context.

Seed instructions:

* Do not include any grape labelled as a table grape.
* Do not include grapes where the only evidence found is table-grape use.
* Include wine-making grapes used for red, white, rosé, orange, sparkling, fortified, and dessert wines.
* Preserve common Latin-script names.
* Avoid non-Latin alphabets in seed display names unless a Latin-script form cannot be found.
* Keep grape rows alphabetized by `name` in the seed file to make manual review easier.
* Because `name` is not unique, do not deduplicate only by English common name. If public sources indicate two different
  grapes share the same common name, create separate grape rows and add notes sufficient for disambiguation.
* Create grape synonym rows for known synonym pairs such as Syrah/Shiraz.
* For synonyms with more than two names, create pairwise synonym relationships only where a public source supports the
  relationship. Do not infer every possible transitive pair unless the source supports it.
* Create appellation-grape rows only where a public source indicates the grape is permitted in that appellation.
* If an appellation has no grape restrictions, create no appellation-grape rows for that appellation.
* Include notes with source/context where helpful for later human review.
* At a bare minimum, create appellation_grapes entries for Bordeaux to include Cabernet Sauvignon, Cabernet Franc, Merlot, Sauvignon Blanc, and Semillon

Recommended seed organization:

* `db/seeds/grape_varieties/` for grape review files, including `world.rb` for broad cross-country seed entries.
* `db/seeds/grape_synonyms.rb` for synonym relationships.
* `db/seeds/appellation_grapes/` with one file per country or other manageable grouping.

After generating the seed files, stop so that I can give preliminary approval before any seeds are run.
