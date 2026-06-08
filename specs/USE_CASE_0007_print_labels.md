# Printed Labels

## Overview
I want to create the actions for printing personal labels for each bottle.  These labels will be QR Code level 4 labels.

There is a gem called rqrcode - before proceeding, check for other gems, for issues with rqrcode, and for recommended best
practices for generating and printing labels with QR codes.

I intend to use a small portable printer, such as the Brother QL-820NWBC.  Ensure that this printer is compatible with the gem(s)
you recommend to me.

Present your analysis to me before processing the file further and let me choose which gem to install.

## Label Content

I want the following elements to be on the label.

For the QR code itself: a URL leading to the bottle show page in QR format. For now, use the placeholder URL "mybottles.tech"; 
place that value in a config file so that it can be easily edited when I make a hosting decision.

For other text and imagery:
* A monocolor version of the favicon
* The name "My Bottles" (again, store in a config file)
* The personal inventory string of the bottle, if any

## UI Elements

Add a toggle "Print labels" and "No labels" to the main menu, similar to the light/dark toggle, and store the value in local
storage for now.

When creating a new bottle, after hitting save, if this toggle is "Print labels", then automatically generate the label and
initiate the appropriate OS print function.

On the bottle show page, add a button "Print labels", which will generate the label and initiate the appropriate OS print function.