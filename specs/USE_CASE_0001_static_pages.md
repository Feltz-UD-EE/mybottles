# Static Pages, Menu, Layout, Logo, and Interactive UI Features

The overall UI of this project should have a clean, easy-to-use interface, suitable for
both desktop and mobile devices.  The default design is for desktops. The UI should support both light mode and dark mode.

There should be a main menu across the top of the screen. Individual menu items will be specified in later use cases,
but for placeholder purposes start with one menu item "My Cellars" that goes nowhere and is just displayed as a placeholder link, and a toggle between light mode and
dark mode. For now, store the light/dark preference in local storage. For small devices, the menu should be accessed through a hamburger icon.  Eventually the menu will
include 2 levels of choices, so add the appropriate dynamic elements now from a standard library like Stimulus.

There should be a logo in the upper left corner, in line with the menu. Clicking on the logo takes the user
to the public home page. Create four alternative logos for me and let me choose which one I want before committing them
to the code base. Logos should be suitable for displaying monochromatically and 
for converting into a modern browser-tab favicon image. Logos should be in SVG format. Logos should be wine-themed: visual elements can be bottles, 
glasses, corkscrews, wine cases, bunches of grapes, etc. For each logo you create, show me the following versions:
* full-color, splash-screen sized
* monochrome, splash-screen sized
* full-color, menu sized
* monochrome, menu sized
* full-color, browser tab version

Temporarily save the logos locally while I decide which to use. Do not interrupt processing - I will decide on which to
use after everything has been built.

There should be a footer across all pages with the following elements, each leading to an appropriately-named static page - 
I have listed these with the title, and then the browser URL in parentheses. Implement the appropriate static routes.
* About (/about)
* Legal (/legal)
* Credits (/credits)
* Signup (/signup)

Create placeholder text for each of those static pages, with the following prompts:
* About: use the top-level README file in this project to provide some simple bullet points about what the project is for.
* Legal: use generic all-rights-reserved and disclaimer language, in the general style of Cellar Tracker and IMDB.
* Credits: just provide placeholders
* Signup: indicate that the project is in closed beta for now, leave a placeholder for an email address to express interest.

The project will include lots of tabular display. I will want tables that can have:
* pagination
* subtle but distinctive alternating row coloration
* a search box
* sorting by column; this is optional and will be specified column by column

The project will include some drag-and-drop UI elements. Include the appropriate dynamic elements now so this can be used
in future use cases.

For the dynamic elements (2-level menu, tabular display, drag-and-drop) include the standard Stimulus package and then
tell me what else will need to be included in the future.  When I write those use cases, I will make the implementation decision
then.