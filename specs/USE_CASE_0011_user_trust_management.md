# User Trust Management

## Overview

Implement trust-management tools for reviewing user contribution quality and promoting or demoting users.

This use case builds on basic user management and users-and-trust workflows. It should not be processed until use cases
0009 and 0010 have been implemented.

The goal is to help Curator and System Administrator users evaluate Basic and Trusted users based on their submitted
community-curated data, then promote users when appropriate.

All tables should be created so that the auto-generated id column is a UUID.

All tables should include standard created_at and updated_at columns.

Table and column descriptions, where possible, should be inserted as metadata to the Postgres schema.

## Navigation

Create a top-level menu item labelled `User Review`.

The `User Review` menu should be visible to Curator and System Administrator users.

For Curator users, show these submenu items:

* `Trusted Users`
* `Basic Users`
* `Stats`

For System Administrator users, show these submenu items:

* `Trusted Users`
* `Basic Users`
* `Stats`
* `All Users`

## Promotion History

Track user promotions and demotions.

Create a `UserTrustEvent` model.

| Name             | Data type | Relationships                    | Description                                   | Constraints                                                   | Notes |
|------------------|-----------|----------------------------------|-----------------------------------------------|---------------------------------------------------------------|-------|
| user_id          | UUID      | user_trust_event belongs to user | The user whose trust level changed            | not null                                                      |       |
| actor_id         | UUID      | user_trust_event belongs to user | The user who changed the trust level          | not null                                                      |       |
| from_trust_level | text      |                                  | Trust level before the change                 | not null, enum: Basic, Trusted, Curator, System Administrator |       |
| to_trust_level   | text      |                                  | Trust level after the change                  | not null, enum: Basic, Trusted, Curator, System Administrator |       |
| action           | text      |                                  | Whether this event is a promotion or demotion | not null, enum: Promotion, Demotion                           |       |
| notes            | text      |                                  | Optional notes about why the change was made  |                                                               |       |

Use `UserTrustEvent` for the Stats page and for auditability.

Also use PaperTrail and public_activity for trust-level changes if those gems have been installed by use case 0010.

## Trusted Users Page

Create a `Trusted Users` page visible to Curator and System Administrator users.

Show a sortable table of all users whose current trust level is `Trusted`.

Use at least these columns:

| column_name                      | Description                                                           |
|----------------------------------|-----------------------------------------------------------------------|
| email                            | User email address                                                    |
| days_since_account_creation      | Number of days since account creation                                 |
| suggested_edits_count            | Number of suggested edits the user has made                           |
| suggested_edits_approved_count   | Number of suggested edits approved                                    |
| suggested_edits_rejected_count   | Number of suggested edits rejected                                    |
| new_entries_count                | Number of new community-curated data entries the user has made        |
| new_entries_approved_count       | Number of new community-curated data entries approved                 |
| new_entries_rejected_count       | Number of new community-curated data entries rejected                 |
| suggested_edits_count_90_days    | Same as `suggested_edits_count`, limited to the past 90 days          |
| suggested_edits_approved_90_days | Same as `suggested_edits_approved_count`, limited to the past 90 days |
| suggested_edits_rejected_90_days | Same as `suggested_edits_rejected_count`, limited to the past 90 days |
| new_entries_count_90_days        | Same as `new_entries_count`, limited to the past 90 days              |
| new_entries_approved_90_days     | Same as `new_entries_approved_count`, limited to the past 90 days     |
| new_entries_rejected_90_days     | Same as `new_entries_rejected_count`, limited to the past 90 days     |

Add a row-level `Promote` button.

Clicking `Promote` promotes the user from `Trusted` to `Curator`.

Only System Administrator and Curator users can view this table, but only System Administrator users can promote a Trusted
user to Curator unless a later use case explicitly allows Curators to create other Curators.

## Trusted User Drill-Down

Create a drill-down page for each Trusted user.

Show:

* User email
* User name
* Current trust level
* Account creation date
* Days since account creation
* All metrics from the Trusted Users table
* A detailed list of all suggested edits submitted by the user
* A detailed list of all new community-curated data entries submitted by the user

Suggested edit details should include:

| column_name  | Description                                                         |
|--------------|---------------------------------------------------------------------|
| submitted_at | When the edit was submitted                                         |
| target_type  | Producer, Wine, or Vintage                                          |
| target       | Record being edited                                                 |
| status       | Pending, Approved, Rejected, Superseded, Merged, or Needs More Info |
| reviewed_at  | When the edit was reviewed                                          |
| reviewed_by  | Reviewer                                                            |
| summary      | Changed fields                                                      |

New-entry details should include:

| column_name     | Description                            |
|-----------------|----------------------------------------|
| created_at      | When the entry was created             |
| entry_type      | Producer, Wine, or Vintage             |
| entry           | New record                             |
| approval_status | Pending, Approved, Rejected, or Merged |
| reviewed_at     | When the entry was reviewed            |
| reviewed_by     | Reviewer                               |
| summary         | Useful identifying details             |

Show a `Promote` button on this page with the same permission rules as the Trusted Users table.

## Basic Users Page

Create a `Basic Users` page visible to Curator and System Administrator users.

Show the same table structure as the Trusted Users page, but include only users whose current trust level is `Basic`.

Add a row-level `Promote` button.

Clicking `Promote` promotes the user from `Basic` to `Trusted`.

Curator and System Administrator users may promote Basic users to Trusted.

## Basic User Drill-Down

Create a drill-down page for each Basic user.

Show the same drill-down structure as the Trusted User drill-down page.

Show a `Promote` button on this page.

Clicking `Promote` promotes the user from `Basic` to `Trusted`.

Curator and System Administrator users may perform this promotion.

## Promotion Splash Screen

When a user is promoted, show a dismissable splash screen congratulating that user the next time they log in or navigate
with the menu.

The splash screen should appear once per promotion event.

Add a `dismissed_at` timestamp to `UserTrustEvent` or create an equivalent acknowledgement mechanism so that a user does
not continue to see the same promotion message after dismissing it.

For promotion to `Trusted`, the splash screen should briefly explain that the user's contributions have earned additional
confidence.

For promotion to `Curator`, the splash screen should:

* Congratulate the user.
* Explain that they can review community-curated Producer, Wine, and Vintage data.
* Provide a synopsis of what they can do with the `User Review` menu.
* Link to the Review queue and User Review pages if the user has access to them.

## Stats Page

Create a `Stats` page visible to Curator and System Administrator users.

Show metrics about current users by trust level.

Use at least these rows or cards:

| metric_name                                 | Description                                                           |
|---------------------------------------------|-----------------------------------------------------------------------|
| basic_users_count                           | Current number of Basic users                                         |
| trusted_users_count                         | Current number of Trusted users                                       |
| curator_users_count                         | Current number of Curator users                                       |
| system_administrator_users_count            | Current number of System Administrator users                          |
| basic_users_created_90_days                 | Number of Basic users whose accounts were created in the past 90 days |
| trusted_users_promoted_90_days              | Number of users promoted to Trusted in the past 90 days               |
| curator_users_promoted_90_days              | Number of users promoted to Curator in the past 90 days               |
| system_administrator_users_promoted_90_days | Number of users promoted to System Administrator in the past 90 days  |

For `Basic`, the 90-day metric is account creation because Basic is the default starting level.

For higher trust levels, the 90-day metric is promotion into that trust level.

## All Users Page

Create an `All Users` page visible only to System Administrator users.

Show a sortable table of all users.

Use at least these columns:

| column_name | Description           |
|-------------|-----------------------|
| email       | User email address    |
| created_at  | Account creation date |
| trust_level | Current trust level   |

Add row-level action buttons:

* `Promote`
* `Demote`

Promotion behavior:

* `Basic` promotes to `Trusted`.
* `Trusted` promotes to `Curator`.
* `Curator` promotes to `System Administrator`.
* `System Administrator` cannot be promoted.

Demotion behavior:

* `Trusted` demotes to `Basic`.
* `Curator` demotes to `Trusted`.
* `System Administrator` users can never be demoted.
* `Basic` cannot be demoted.

System Administrator users can promote or demote any non-System Administrator user.

System Administrator users can promote a Curator to System Administrator.

System Administrator users can never demote another System Administrator or themselves from System Administrator.

Every promotion and demotion should create a `UserTrustEvent`.

## Metric Definitions

Suggested edits are `ProposedChange` records where `proposed_by_user_id` is the user.

Suggested edits approved are `ProposedChange` records where:

* `proposed_by_user_id` is the user.
* `status = Approved`.

Suggested edits rejected are `ProposedChange` records where:

* `proposed_by_user_id` is the user.
* `status = Rejected`.

New community-curated entries are Producer, Wine, and Vintage records where `created_by_user_id` is the user.

New entries approved are Producer, Wine, and Vintage records where:

* `created_by_user_id` is the user.
* `approval_status = Approved`.

New entries rejected are Producer, Wine, and Vintage records where:

* `created_by_user_id` is the user.
* `approval_status = Rejected`.

For 90-day metrics, filter by the submission or creation timestamp:

* Suggested edits use `submitted_at`.
* New entries use `created_at`.

## Authorization Rules

Use Pundit policies.

Curator users can:

* View the User Review menu.
* View Trusted Users, Basic Users, Stats, and drill-down pages.
* Promote Basic users to Trusted.

System Administrator users can:

* Do everything Curator users can do.
* View All Users.
* Promote Trusted users to Curator.
* Promote Curator users to System Administrator.
* Demote Trusted users to Basic.
* Demote Curator users to Trusted.

System Administrator users cannot:

* Demote any System Administrator user.
* Demote themselves from System Administrator.

Basic and Trusted users cannot access User Review pages.

## Tests

Build tests for:

* User Review menu visibility by trust level.
* Trusted Users table metrics.
* Trusted User drill-down details.
* Basic Users table metrics.
* Basic User drill-down details.
* Basic-to-Trusted promotion.
* Trusted-to-Curator promotion permissions.
* Curator-to-System Administrator promotion permissions.
* Demotion permissions.
* Prevention of System Administrator demotion.
* UserTrustEvent creation for promotions and demotions.
* Promotion splash screen appears once per promotion.
* Curator promotion splash screen includes User Review synopsis.
* Stats page counts by current trust level.
* Stats page 90-day promotion metrics.
* All Users table sorting.
* All Users authorization.
