# Users And Trust

## Overview

Implement trust-based workflows for shared community data.

This use case builds on basic user management. It should not be processed until the basic user management use case has
been implemented.

The goal is to allow users to manage their own cellar data freely while protecting shared canonical data such as Producers,
Wines, and Vintages through a review process similar to wisdom-of-crowds sites.

All tables should be created so that the auto-generated id column is a UUID.

All tables should include standard created_at and updated_at columns.

Table and column descriptions, where possible, should be inserted as metadata to the Postgres schema.

## Gems

Install and configure the following gems:

* `paper_trail` for audit and version history.
* `public_activity` as the user activity tracking gem.

Use `paper_trail` to record who changed canonical records and who approved, rejected, or merged proposed changes.

Use `public_activity` to create activity records for community-data events such as proposed creates, proposed edits,
approvals, rejections, duplicate merges, and reviewer comments.

## Data Buckets

Divide application data into the following buckets.

### Private User-Owned Data

This data belongs to a specific user and can be freely edited by that user.

Initial models:

* Bottles
* Cellars
* Bins
* Bays
* Shelves
* Tasting Notes, unless a later use case makes some tasting notes public
* Wine Clubs
* Watch List Entries

User ownership for these records should already have been added in use case 0009. If any private user-owned model still
lacks ownership when this use case is processed, stop and ask before continuing.

Policy:

* The owning user can create, read, update, and delete their own records.
* System Administrator users can administer all records.
* Other users cannot see private user-owned data.

### Administrator-Governed Reference Data

This data is site-wide reference data and can only be edited directly by a System Administrator.

Initial models:

* Countries
* Regions, backed by Appellation
* User trust levels
* Any future site-wide reference tables

Policy:

* Public and signed-in users may read public reference data as permitted by use case 0009.
* Only System Administrator users can create, update, delete, seed, or otherwise directly administer this data.

### Community-Curated Canonical Data

This data is shared across users and should be protected by a trust workflow.

Initial models:

* Producers
* Wines
* Vintages

Policy:

* Approved canonical records are visible to appropriate public and signed-in users.
* Low-trust users may submit new records and edits.
* Low-trust edits to approved canonical records must not overwrite canonical data before review.
* Curator and System Administrator users may review pending creates and edits.

## Shadow Records Design Pattern

Use the shadow records design pattern for low-trust creation of community-curated data.

When a low-trust user creates a new Producer, Wine, or Vintage:

* Create a real row in the appropriate table.
* Mark it with `approval_status = Pending`.
* Set `created_by_user_id` to the submitting user.
* Allow the submitting user to use the pending row in their own cellar workflow.
* Do not expose the pending row to other low-trust users.
* Show the submitting user a visual `Pending review` tag anywhere that row appears.

This pattern is required because a user must be able to attach Wines, Vintages, and Bottles to pending data before that data
has been approved as canonical.

## Approval Fields For Community-Curated Models

Add the following columns to Producers, Wines, and Vintages.

| Name                | Data type | Relationships                    | Description                                     | Constraints                                         | Notes                                 |
|---------------------|-----------|----------------------------------|-------------------------------------------------|-----------------------------------------------------|---------------------------------------|
| approval_status     | text      |                                  | Review status for this record                   | not null, enum: Pending, Approved, Rejected, Merged | Default Pending for low-trust creates |
| created_by_user_id  | UUID      | user belongs to user             | User who first created this record              |                                                     |                                       |
| approved_by_user_id | UUID      | user belongs to user             | User who approved this record                   |                                                     |                                       |
| approved_at         | datetime  |                                  | When this record was approved                   |                                                     |                                       |
| rejected_by_user_id | UUID      | user belongs to user             | User who rejected this record                   |                                                     |                                       |
| rejected_at         | datetime  |                                  | When this record was rejected                   |                                                     |                                       |
| merged_into_id      | UUID      | same model belongs to same model | Canonical record this duplicate was merged into |                                                     | Self-reference                        |

Existing Producers, Wines, and Vintages should be backfilled as `Approved`.

System Administrator and Curator-created records may be created as `Approved` immediately.

Basic and Trusted user-created records should default to `Pending`.

## Proposed Changes

Use a `ProposedChange` model for edits to existing approved Producers, Wines, and Vintages.

Low-trust edits must be stored as proposed changes and must not mutate the canonical record until approval.

| Name                | Data type | Relationships        | Description                                      | Constraints                                                                      | Notes                                     |
|---------------------|-----------|----------------------|--------------------------------------------------|----------------------------------------------------------------------------------|-------------------------------------------|
| target_type         | text      | polymorphic          | The model type being changed                     | not null                                                                         | Producer, Wine, or Vintage                |
| target_id           | UUID      | polymorphic          | The record being changed                         | not null                                                                         |                                           |
| proposed_by_user_id | UUID      | user belongs to user | User who submitted the proposal                  | not null                                                                         |                                           |
| reviewed_by_user_id | UUID      | user belongs to user | User who reviewed the proposal                   |                                                                                  |                                           |
| status              | text      |                      | Review status                                    | not null, enum: Pending, Approved, Rejected, Superseded, Merged, Needs More Info | Default Pending                           |
| action              | text      |                      | What kind of proposal this is                    | not null, enum: Update, Merge                                                    |                                           |
| proposed_attributes | jsonb     |                      | Proposed attribute values                        | not null                                                                         | Only include changed fields               |
| original_attributes | jsonb     |                      | Canonical values when the proposal was submitted | not null                                                                         | Used for review diffs and drift detection |
| reviewer_attributes | jsonb     |                      | Reviewer-edited values applied at approval       |                                                                                  | Used for Edit and Approve                 |
| duplicate_of_type   | text      | polymorphic          | Proposed canonical duplicate target type         |                                                                                  | For merge proposals                       |
| duplicate_of_id     | UUID      | polymorphic          | Proposed canonical duplicate target id           |                                                                                  | For merge proposals                       |
| review_notes        | text      |                      | Notes from reviewer                              |                                                                                  |                                           |
| submitted_at        | datetime  |                      | When the proposal was submitted                  | not null                                                                         |                                           |
| reviewed_at         | datetime  |                      | When the proposal was reviewed                   |                                                                                  |                                           |

Use `jsonb` for `proposed_attributes`, `original_attributes`, and `reviewer_attributes`.

Use JSONB only for pending proposals and review snapshots. Do not move canonical Producer, Wine, or Vintage attributes into
JSONB.

## Multiple Pending Edits

Allow more than one pending proposed change for the same target.

Do not automatically collapse multiple proposals into a single row.

On review, show all pending proposals for the same target together so a reviewer can compare them.

When approving a proposed change:

* Check whether the target record's current values still match `original_attributes`.
* If they do not match, show a drift warning before approval.
* The reviewer can still approve, edit and approve, reject, or supersede the proposal.

When one proposal is approved, other pending proposals for the same target should remain pending unless the reviewer marks
them as superseded.

## Duplicate Merge Behavior

Curator and System Administrator users need a way to resolve duplicate Producers, Wines, and Vintages.

When a pending shadow record is a duplicate:

* Reviewer chooses the canonical target record.
* System repoints dependent records from the duplicate to the canonical target.
* System marks the duplicate record `Merged`.
* System sets `merged_into_id`.
* System creates PaperTrail and public_activity records for the merge.

For Producers, repoint dependent Wines where appropriate.

For Wines, repoint dependent Vintages where appropriate.

For Vintages, repoint dependent Bottles, Tasting Notes, Watch List Entries, and other dependent records where appropriate.

Merge operations must be wrapped in a database transaction.

Never hard-delete merged community-curated records in this use case.

## Visibility Rules

Approved community-curated records:

* Visible to public users where public pages allow them.
* Visible to signed-in users.

Pending community-curated records:

* Visible to the user who submitted them.
* Visible to Curator and System Administrator users.
* Not visible to other Basic or Trusted users.

Rejected community-curated records:

* Visible to the submitter with a rejected tag.
* Visible to Curator and System Administrator users.
* Not visible to other users.

Merged community-curated records:

* Visible to Curator and System Administrator users.
* Submitter should be redirected or messaged toward the canonical merged target.
* Normal users should see only the canonical target.

## UI Tags

Where pending, rejected, or merged community-curated rows appear to users who are allowed to see them, display a small visual
status tag:

* `Pending review`
* `Rejected`
* `Merged`

For a user who submitted a pending edit to an approved record, show the approved canonical record with a small tag:

`Your edit is awaiting review`

The submitting user may see their proposed values in a visually distinct overlay or comparison panel, but other users should
continue to see canonical values.

## Review Queue

Create a top-level menu item labelled `Review`.

Only Curator and System Administrator users can see this menu item.

Create review queue routes:

* `/review`
* `/review/producers`
* `/review/wines`
* `/review/vintages`
* `/review/proposed_changes/:id`

The main review queue should show both pending shadow records and pending proposed changes.

Use a dense table with at least these columns:

| column_name  | Description                                         |
|--------------|-----------------------------------------------------|
| type         | Producer, Wine, Vintage, or Proposed Change         |
| target       | Name of the record or proposed record               |
| action       | Create, Update, or Merge                            |
| submitted_by | User who submitted the item                         |
| age          | How long it has been waiting                        |
| summary      | Changed fields, new-record summary, or merge target |
| status       | Current review status                               |

Default sort order should be oldest pending item first.

Include filters for:

* type
* action
* submitted_by
* status
* age

## Review Detail Pages

A review detail page should show:

* Submitter
* Submitted timestamp
* Current canonical values, if any
* Proposed values
* Original values at time of submission
* Field-by-field diff
* Drift warning if canonical values changed after submission
* Related dependent records affected by approval or merge
* Possible duplicate matches
* Activity history

Actions available to reviewers:

* `Approve`
* `Edit and Approve`
* `Reject`
* `Merge as Duplicate`
* `Needs More Info`
* `Supersede`

`Edit and Approve` should allow the reviewer to adjust the submitted values before applying them.

`Reject`, `Needs More Info`, and `Supersede` should require review notes.

`Merge as Duplicate` should require selecting the canonical target.

## Activity And Audit

Use PaperTrail on:

* User
* Producer
* Wine
* Vintage
* ProposedChange
* Private user-owned models from use case 0009

Configure PaperTrail whodunnit using the signed-in user.

Use public_activity to create feed-style records for:

* Pending create submitted
* Pending edit submitted
* Proposal approved
* Proposal edited and approved
* Proposal rejected
* Proposal marked needs more info
* Proposal superseded
* Duplicate merged
* Trust level changed

Activity records should include enough parameters to display a meaningful review timeline without querying PaperTrail for
every list row.

## Tests

Build tests for:

* Ownership enforcement for private user-owned data.
* System Administrator-only direct editing for Countries and Regions.
* Shadow record creation by Basic and Trusted users.
* Immediate approval for Curator and System Administrator-created community records.
* Pending shadow records visible to submitter and reviewers only.
* ProposedChange creation for edits to approved Producers, Wines, and Vintages.
* Canonical record unchanged while a ProposedChange is pending.
* Multiple pending proposals for the same target.
* Drift warning when canonical values change before approval.
* Approve behavior.
* Edit-and-approve behavior.
* Reject behavior.
* Needs-more-info behavior.
* Supersede behavior.
* Merge-as-duplicate behavior and dependent-record repointing.
* PaperTrail whodunnit.
* public_activity event creation.
* Review queue authorization.
* Review queue filters and default sort order.
