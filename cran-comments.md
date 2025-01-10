## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

Initial submission was on 2025-08-01, this is a resubmission after fixing the issues raised by the CRAN team.

* changed cat() to message() to allow suppression of messages
* removed a spurious if(interactive()){} wrapper in one of the examples
* added a missing return value in function documentation
* reformat URL in DESCRIPTION
