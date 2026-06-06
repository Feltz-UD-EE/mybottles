I think and write in terms of a properly-normalized data architecture.  If I specify something that does not seem to adhere to the rules of normalization, ask for clarification.

This data architecture will make use of the Rails has_many through construct. There will be numerous model helper 
methods to collapse these associations for display.

This data architecture will make use of polymorphic associations.

This data architecture will include some self-referential models to express nested parent-child relationships, especially for geography 
and associated wine appellations - see this [Wikipedia article](https://en.wikipedia.org/wiki/Appellation) for an overview of what 
appellations are. These models will support multiple parent-child generations.

This data architecture will make some use of JSON structures as columns, but only for edge cases where normalization would be 
a heavy effort for little gain.

I will be providing explicit data structure instructions in many use cases, due to my experience in the wine industry. Ask questions if
you don't understand those instructions. 

