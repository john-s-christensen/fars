getwd()
setwd("C:/Users/john.christensen/Box Sync/John Christensen/Data Science/Coursera Mastering Software Development in R/Course 3 - Building R Packages/Week 4 - Peer Graded Assignment")
getwd()
dir.create("farsPackage_NEW")
dir()
setwd("farsPackage_NEW/")
getwd()

devtools::create("fars")

setwd("fars/")

# Per Hadley's instructions, I'm now going to double click on the R project file that was just created using the devtools::create() function.
# http://r-pkgs.had.co.nz/package.html

# I want to ignore this file when the package is built!:
devtools::use_build_ignore("CreatingAnRPackage.R")


# Copy my .R files from _OLD and paste them here: this worked!
old_folder <-
  "C:/Users/john.christensen/Box Sync/John Christensen/Data Science/Coursera Mastering Software Development in R/Course 3 - Building R Packages/Week 4 - Peer Graded Assignment/farsPackage_OLD/R/fars_functions.R"
new_folder <- "C:/Users/john.christensen/Box Sync/John Christensen/Data Science/Coursera Mastering Software Development in R/Course 3 - Building R Packages/Week 4 - Peer Graded Assignment/farsPackage_NEW/fars/R/"
file.copy(old_folder, new_folder)


# Add packages to my descrition file that my package needs in order to run (things that I call with package::fun())
devtools::use_package("dplyr")
devtools::use_package("graphics")
devtools::use_package("maps")
devtools::use_package("readr")
devtools::use_package("tidyr")

# I copied the LICENSE file from healthcare.ai into this working folder and modified it.

# left off here:
# http://r-pkgs.had.co.nz/man.html


# Generate documentation from roxygen2 comments (creates the \man directory, which contains .Rd files, which document and come up when
#     someone types ?function or help(function):
devtools::document()

# Finished reading about the \man directory and left off here:
# http://r-pkgs.had.co.nz/vignettes.html

browseVignettes("fars")

# Create the vignette:
devtools::use_vignette("farsVignette")
# I then edited the vignette template.
devtools::load_all()
# I left off not knowing how to knit my vignette to see it. Also worried about _____ something else?
# Added library, but didn't seem to work.  Load_all() didn't work.

# It turns out that I had to build and install my own package and include libary(fars) in the vignette. This worked!
# After running this command I was able to knit my vignette.
devtools::install()

devtools::build()
# Don't think that did much.




# Creating automated unit tests using testthat:
# http://r-pkgs.had.co.nz/tests.html
devtools::use_testthat() #this created tests/testthat.R
# I then opened the testthat.R file and created a test.

# can I test functions that aren't exported?
# Yes. But Hadley recommends testing at the user facing level, rather than the internal function level?

# From Hadley: Test your package with Ctrl/Cmd + Shift + T or
devtools::test()
# above didn't work... got this error:
# No tests: no files in C:\Users\john.christensen\Box Sync\John Christensen\Data Science\Coursera Mastering Software Development in R\Course 3 - Building R Packages\Week 4 - Peer Graded Assignment\
# farsPackage_NEW\fars/tests/testthat match '^test.*\.[rR]$'
# Here is the issue, from Hadley:
# "A test file lives in tests/testthat/. Its name must start with test. Here’s an example of a test file from the stringr package:"
# Interesting that devtools::use_testthat() creates the test file outside of the tests/testthat folder where it ultimately needs to be.
# I'm just going to cut and paste the file to that folder and try again.
devtools::test()

# Cool, it ran, but the test failed with: "No tests found for fars"
# Looked at the code and realized that it throws a warning, not an error. Changed the test code from expect_error to expect_warning.
# Trying again:
devtools::test()
# Took out second argument:
devtools::test()


# What I finally realized is that I wrote my tests in the file that the devtools::use_testthat() function created - tests/testthat.R.
# I shouldn't have modified that file. So I created a new file in tests/testthat/ and called it testYears b/c hadley says you
# have to call it "test_____".
# Trying again:
devtools::test()
# that at least found the test and threw a warning!!!!
# I wonder if it's okay that it says OK but also has a warning. I'm not sure yet what the warning means.
devtools::check()
# It failed the first time with error:
# "Namespace dependency not required: 'magrittr'"
# because I had "importFrom(magrittr,"%>%")" in my NAMESPACE file, but no mention of magrittr in my DESCRIPTION file in the "Depends" section.

devtools::check()
# failed again with this:
#* checking examples ... ERROR
#unning examples in 'fars-Ex.R' failed
#The error most likely occurred in:

#  > base::assign(".ptime", proc.time(), pos = "CheckExEnv")
#> ### Name: fars_read
#  > ### Title: Import .csv flat files
#  > ### Aliases: fars_read
#  >
#  > ### ** Examples
#  >
#  > fars_read("accident_2015.csv.bz2")
# Error in fars_read("accident_2015.csv.bz2") :
#  could not find function "fars_read"
# Execution halted


# Trying again:
devtools::check()
# Same error.

# based on this: http://r-pkgs.had.co.nz/check.html, I'm running
devtools::check_man()
# This called devtools::document() and it returned "No issues detected".  Trying again:
devtools::check()
# same error. Based on hadley's advice in the link above under the "Checking examples" bullet, I'm going to run:
devtools::run_examples()
# failed with this:
#Running examples in fars_read.Rd -------------------------------------------------------------------------------------------------------
#  >
#  > fars_read("accident_2015.csv.bz2")
#Error in fars_read("accident_2015.csv.bz2") :
#  could not find function "fars_read"

# I think I know what the issue is! I didn't export those functions because they're not user facing! Hence, they have examples, but aren't exported. I'm either going to export them or remove the example or put don't test? Might need it for the assignment, so I'm going to export them!
devtools::run_examples()
# That change did the trick!!!  Going back to
devtools::check()
# Now it passed with no errors and no warnings, only 1 note:
#checking R code for possible problems ... NOTE
#fars_map_state: no visible binding for global variable 'STATE'
#fars_read_years : <anonymous>: no visible binding for global variable
#'MONTH'
#fars_summarize_years: no visible binding for global variable 'year'
#fars_summarize_years: no visible binding for global variable 'MONTH'
#fars_summarize_years: no visible global function definition for 'n'
#fars_summarize_years: no visible binding for global variable 'n'
#Undefined global functions or variables:
#  MONTH STATE n year

# for that check, hadley says that this function is called:
# codetools::checkUsagePackage() is called to check that your functions don’t use variables that don’t exist.
# This sometimes raises false positives with functions that use non-standard evaluation (NSE), like subset() or with().
# Generally, I think you should avoid NSE in package functions, and hence avoid this NOTE, but if you can not,
# see ?globalVariables for how to suppress this NOTE.
http://r-pkgs.had.co.nz/check.html

# I can't remember what NSE is...


devtools::run_examples()

# Just read his from Hadley:
# "you can’t use unexported functions and you"
# http://r-pkgs.had.co.nz/check.html
# I'm wondering if an example cant have a function that calls an unexported function??? Will test by exporting those? with & withut dontrun.



# Okay, so something is really up with the \dontrun{} option that i tried to do. once i removed it it all works.
# My memory is that if i dont export these it still tries to run the examples. Might try to unexpot & remove examples, even though i probably want them for the assignment.

# Going to recheck everything to make sure it works first.

devtools::check()
# Okay, so since doing that (& since initializing local variables in the function as NULL), it passes without error, warning or note!

# one lesson learned is that you cant pass checks by unexporting the function & having an example on it, even if you have \dontrun on the example.






###################################
### TRAVIS - I WANT TO MASTER ALL THIS STUFF.  I REALLY WNJOY CODE DEVELOPMENT1
###################################


# http://r-pkgs.had.co.nz/check.html#travis
devtools::use_travis()
# To use Travis:
  # Run devtools::use_travis() to set up a basic .travis.yml config file.
  # Navigate to your Travis account and enable Travis for the repo you want to test.
  # Commit and push to GitHub.
      # NEED TO FILL IN HERE THE COOL THINGS I LEARNED & WHERE I LEARNED THEM!
        # Followed this: http://r-pkgs.had.co.nz/git.html#git
        # Under "Git" in R Studio, hit the Commit button.
        # This opens a window where you can select all records & stage them, then commit them.
        # Then hit Push to send changes up to GitHub.
  # Wait a few minutes to see the results in your email.


# Now reading through:
# http://r-pkgs.had.co.nz/git.html#git
file.exists("~/.ssh/id_rsa.pub")

# tO ADD tRAVIS BUILD BADGE TO README.MD:
# https://docs.travis-ci.com/user/status-images/

# CATCHING UP ON ReadMe.md docs, which i had forgotten about:
  # https://bookdown.org/rdpeng/RProgDA/documentation.html#vignettes-and-readme-files

# I first need to create a ReadMe file, then render it as md? & then add my travis staus icon to it.

?devtools::use_readme_rmd
devtools::use_readme_rmd()
# This is super cool b/c the above function will render the .mdfile from the .Rmd file after you "knit"!
