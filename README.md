# Project My Bottles

## About

My personal wine cellar and tasting notes project - a greenfield redevelopment of my 
previous Rails projects that_bottle.

## Intended use

* Keep track of purchases and inventory
* Manage tasting notes, both of what I own and what I taste when visiting wineries, wine stores, etc
* Create watch lists of wines I particularly want to find or purchase again

## Development Process

My Bottles is being created as a largely GenAI spec-driven development (SDD) project, with some initial
data normalization instructions based on my knowledge of the wine industry (especially appellation law) 
and past experience with that_bottle.

Specification documents will be created in a separate directory that Codex will read from.

## Overview of use cases

### Regular use cases
* Purchased a bottle: record details about the purchase - link the bottle to an existing instance of the wine if it exists. This will eventually also allow me to print a QR code label to put on the bottle for easy in consumption and inventory.
* Consumed a bottle: mark the bottle as having been consumed, gifted, spoiled, etc and link to tasting notes if appropriate.
* Tasted a wine: create tasting notes for tasting wine that isn't one of the bottles in my cellar.
* Search cellar: find a bottle in the cellar - either a specific bottle or an open-ended category search ("old Bordeaux")
* Watch list: add wines to my watch list, access the watch list.

### Maintenance use cases
* Define the cellar: specify the particular dimensions and storage capacity of my cellar at home, and any other storage locations (eg wine fridge)
* Inventory: scan through every bottle in the cellar and identify any discrepancies (duplicate QR labels, missing bottles, unlabelled bottles)
* Define industry specs: upload appellations, grapes, etc. from reference materials
* People management: invite others to create their own accounts, grant others read-only access to my cellar, profile management, password resets, etc
* Cellar upload: upload the info about my current wine collection as a bootstrap.
* Data management: find typos, edit entries, general CRUD management.
