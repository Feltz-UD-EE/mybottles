How to read and process instructions in the specs directory:

This project uses spec-driven development (SDD).  All specifications (with the exception of
the main-level `README` and `BOOTSTRAP` files) are contained in this directory.

Always read any file starting with `PRINCIPLES_` first - these files specify the overall architecture,
naming standards, philosophy, and other general concepts about the project. These files will be updated
from time to time, so always reread them before creating any features.

Files starting with `USE_CASE_` specify individual features.  They will be numbered sequentially with a 4-digit number, 
followed by a plain-english description. The plain-english description is only for my use, you should never consider the 
plain-english part of the file name when designing features.

Example: `USE_CASE_0001_static_pages.md`

I will instruct you which use case files to read in order to build a feature.  Old use case files should be read only 
for context about previous work. There will be draft and in-process use case files that should not be read unless I explicitly
tell you to read them.

You should always build tests when building new features.

After building a new feature, do the following:
* if necessary, run migrations
* if necessary, run database seeds
* restart the local server
* run tests
