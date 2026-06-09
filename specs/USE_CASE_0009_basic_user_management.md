# Basic User Management

## Overview

Add basic user accounts, authentication, authorization, invitations, and user-level profile preferences.

This use case introduces multiple users but does not yet implement community trust workflows. See the next use case for
review queues, shadow records, user activity, and trust-based governance of shared data.

All tables should be created so that the auto-generated id column is a UUID.

All tables should include standard created_at and updated_at columns.

Table and column descriptions, where possible, should be inserted as metadata to the Postgres schema.

## Gems

Install and configure the following gems:

* `devise` for user authentication.
* `pundit` for authorization policies.

Use Devise's built-in modules for database authentication, registration as appropriate, recoverable passwords, remember-me
sessions, validatable email/password rules, and invitations as described below.

Configure Devise so that remember-me login tokens last for 30 days.

Configure Pundit globally in `ApplicationController`. Authorization checks should be enforced for private resources and
for administrative actions.

## Trust Levels

Create four user trust levels. These should be stored as a Rails enum and as a Postgres constraint.

Use the following values, capitalized exactly for UI display and validations:

* Basic
* Trusted
* Curator
* System Administrator

The highest level is `System Administrator`.

Initial intent:

* `Basic` users can edit their own private inventory data and submit community data for review.
* `Trusted` users are known users with more confidence but are not reviewers by default.
* `Curator` users can review community-submitted producer, wine, and vintage data.
* `System Administrator` users can administer users, trust levels, countries, regions, and other site-wide settings.

## User Model

Create a Devise-backed `User` model.

| Name                    | Data type | Relationships        | Description                                            | Constraints                                                   | Notes                                  |
|-------------------------|-----------|----------------------|--------------------------------------------------------|---------------------------------------------------------------|----------------------------------------|
| email                   | text      |                      | The user's email address                               | not null, unique                                              | Devise managed                         |
| encrypted_password      | text      |                      | Devise encrypted password                              | not null                                                      | Devise managed                         |
| trust_level             | text      |                      | The user's trust level                                 | not null, enum: Basic, Trusted, Curator, System Administrator | Default Basic                          |
| name                    | text      |                      | The user's display name                                |                                                               |                                        |
| theme_preference        | text      |                      | The user's preferred visual theme                      | enum: Light, Dark, System                                     | Default System                         |
| print_labels_by_default | boolean   |                      | Whether bottle creation should print labels by default | not null                                                      | Default false                          |
| invitation_token        | text      |                      | Token used for invitations                             | unique where present                                          | Devise or app-managed                  |
| invitation_created_at   | datetime  |                      | When an invitation was created                         |                                                               |                                        |
| invitation_sent_at      | datetime  |                      | When an invitation was sent                            |                                                               |                                        |
| invitation_accepted_at  | datetime  |                      | When an invitation was accepted                        |                                                               |                                        |
| invited_by_id           | UUID      | user belongs to user | The user who sent the invitation                       |                                                               | Self-reference                         |
| reset_password_token    | text      |                      | Token used for password reset                          | unique where present                                          | Devise managed                         |
| reset_password_sent_at  | datetime  |                      | When password reset instructions were sent             |                                                               | Devise managed                         |
| remember_created_at     | datetime  |                      | When the remember-me session was created               |                                                               | Devise managed                         |
| sign_in_count           | integer   |                      | Number of sign-ins                                     | not null                                                      | Devise managed if trackable is enabled |
| current_sign_in_at      | datetime  |                      | Current sign-in timestamp                              |                                                               | Devise managed if trackable is enabled |
| last_sign_in_at         | datetime  |                      | Previous sign-in timestamp                             |                                                               | Devise managed if trackable is enabled |
| current_sign_in_ip      | text      |                      | Current sign-in IP                                     |                                                               | Devise managed if trackable is enabled |
| last_sign_in_ip         | text      |                      | Previous sign-in IP                                    |                                                               | Devise managed if trackable is enabled |

Use Devise defaults where Devise expects specific column names.

## System Administrator Bootstrap

Create bootstrap logic for the initial system administrator.

The system administrator email is:

`johncfeltz@gmail.com`

Use an environment variable for the initial password so that it can be configured locally and in a future hosting
environment without changing source code:

`MYBOTTLES_SYSTEM_ADMIN_PASSWORD`

If the app is run in development and this environment variable is missing, use a clearly named local fallback value in an
appropriate non-production config file. Do not use a production fallback password.

The bootstrap should be idempotent:

* If no user exists with `johncfeltz@gmail.com`, create one with trust level `System Administrator`.
* If the user already exists, ensure the trust level is `System Administrator`.
* Do not overwrite an existing administrator password unless explicitly instructed by a seed task or environment flag.

This bootstrap should be easy to adapt to a hosting platform's environment-variable system.

## My Profile

Create a top-level menu item labelled `My profile`.

The `My profile` page should allow the signed-in user to view and update:

* Name
* Email, using Devise-safe update behavior
* Password, using Devise-safe update behavior
* Theme preference
* Print labels by default

Move the existing light/dark mode setting out of local storage and store it as `theme_preference` on the user.

Move the existing print-label default setting out of local storage and store it as `print_labels_by_default` on the user.

When a signed-in user changes either setting, persist it to the database. The UI may still use JavaScript for immediate
feedback, but the database value is authoritative.

For anonymous users on public pages, use `System` theme preference and `print_labels_by_default = false`.

## Private Data Ownership

Add ownership concepts for private user-owned data in this use case.

Private user-owned data belongs to a specific user and can be freely edited by that user.

Initial private user-owned models:

* Bottles
* Cellars
* Bins
* Bays
* Shelves
* Tasting Notes
* Wine Clubs
* Watch List Entries

Add `user_id` ownership to these records where missing.

For child records whose ownership can be inferred through a parent record, still include direct ownership where it makes
authorization simpler and avoids expensive joins. The direct owner should remain consistent with the parent owner.

Use the following ownership column pattern:

| Name    | Data type | Relationships        | Description                   | Constraints | Notes |
|---------|-----------|----------------------|-------------------------------|-------------|-------|
| user_id | UUID      | record belongs to user | The user who owns this record | not null    |       |

Existing private records should be assigned to the system administrator during migration or seed backfill.

Policy:

* The owning user can create, read, update, and delete their own private records.
* System Administrator users can administer all private records.
* Other users cannot see private user-owned data.
* Public users cannot see private user-owned data.

For create forms, default `user_id` to the signed-in user. Do not expose a normal user-selectable owner dropdown to Basic,
Trusted, or Curator users.

If a System Administrator creates or edits private data on behalf of another user, the UI may expose an owner selector only
to System Administrator users.

## Invite User

Create an `Invite User` function available only to `System Administrator` users.

Invitations should be valid for 30 days.

An invitation should capture:

| Name                  | Data type | Relationships        | Description                              | Constraints      | Notes              |
|-----------------------|-----------|----------------------|------------------------------------------|------------------|--------------------|
| email                 | text      |                      | Email address being invited              | not null         |                    |
| trust_level           | text      |                      | Initial trust level for the invited user | not null         | Default Basic      |
| invited_by_id         | UUID      | user belongs to user | User who sent the invitation             | not null         |                    |
| invitation_token      | text      |                      | Secure invitation token                  | not null, unique |                    |
| invitation_sent_at    | datetime  |                      | When the invitation was sent             | not null         |                    |
| invitation_expires_at | datetime  |                      | When the invitation expires              | not null         | 30 days after sent |
| accepted_at           | datetime  |                      | When the invitation was accepted         |                  |                    |

Use Devise Invitable for this feature. Align this structure with Devise Invitable's expected columns instead of creating a duplicate
invitation table.

Invite flow:

* System Administrator enters email and desired initial trust level.
* System emails an invitation link.
* Invitee follows the link, sets a password, and completes the account.
* Expired invitations cannot be accepted.
* Accepted invitations cannot be reused.

## Public And Private Pages

Wire up the following page access rules.

### Public Landing Page

Create a public landing page available to anonymous users.

Anonymous users can only see:

* Producers
* Wines
* Regions

Public users must not see:

* Bottles
* Cellars
* Bins
* Bays
* Shelves
* Wine clubs
* Tasting notes
* Watch list
* User administration
* Review queues

Public producers, wines, and regions should be read-only.

### Login Page

Create and style a login page using Devise routes and forms.

### Forgot Password Page

Create and style a forgot password page using Devise recoverable routes and forms.

### Private Landing Page

Create a private landing page for signed-in users.

The private landing page should become the normal signed-in home page and should include the normal application information
and menu access.

Anonymous users visiting private URLs should be redirected to the login page.

Signed-in users visiting the public landing page may either remain there or be offered a clear path to the private landing
page.

## Authorization Rules

Use Pundit policies to express these rules.

Basic initial policy:

* Anonymous users may read public producers, wines, and regions.
* Signed-in users may read normal private app pages.
* Signed-in users may create, read, update, and delete their own private records.
* System Administrator users may administer users and site-wide reference data.
* Trust workflows for Producers, Wines, and Vintages are deferred to use case 0010.

## Tests

Build tests for:

* User model validations and enums.
* System administrator bootstrap behavior.
* Remember-me duration configuration.
* Invitation creation, expiration, acceptance, and reuse prevention.
* Login page.
* Forgot password page.
* Anonymous public landing page access.
* Anonymous private page redirect.
* Signed-in private landing page access.
* My profile update behavior.
* Ownership backfill for existing private records.
* Owner-only access for private records.
* Pundit policy behavior for public, signed-in, and system administrator users.
