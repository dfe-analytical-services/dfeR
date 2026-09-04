# Diagnosing your R setup

If you are struggling with R, Git or `renv` on your DfE laptop, the
[`diagnostic_test()`](https://dfe-analytical-services.github.io/dfeR/reference/diagnostic_test.md)
function in `dfeR` can help you work out what is going on. It runs a
series of checks against your machine and reports which settings look
healthy and which are likely to be causing you trouble.

By default the function is read-only and only tells you what it has
found. If you would like it to attempt to fix things for you, you can
run it with `clean = TRUE`, but you should always run it once without
that argument first so that you can see what would change before
anything is altered.

``` r

dfeR::diagnostic_test()
```

## Reading the summary

Each check finishes with a status. The summary line at the bottom of the
output tells you how many checks fell into each category:

- **PASS** means the check found nothing to worry about.
- **FAIL** means the check found a setting that is likely to cause
  problems. Running with `clean = TRUE` will attempt to fix most of
  these.
- **FIXED** means the check found a problem and was able to fix it
  during this run (you only see this when you call the function with
  `clean = TRUE`).
- **INFO** is for checks that simply report information back to you,
  such as the path to your global Git config file. These are never
  failures.

If everything has come back as **PASS** or **INFO**, you can stop here.
If anything has failed, the rest of this vignette walks through each
check in turn and explains what to do.

## Proxy settings

[`check_proxy_settings()`](https://dfe-analytical-services.github.io/dfeR/reference/check_proxy_settings.md)
looks for proxy entries in your global Git config (`http.proxy`,
`https.proxy`) and in the system environment variables (`http_proxy`,
`https_proxy`, `no_proxy`).

These settings used to be needed inside the DfE network years ago, but
they now prevent Git from connecting to GitHub and Azure DevOps. If you
see an error like:

    fatal: unable to access 'https://...': Could not resolve proxy: mwg.proxy.ad.hq.dept

then this is almost certainly what is causing it.

Running `check_proxy_settings(clean = TRUE)` will clear the Git config
entries and remove the proxy environment variables. On Windows it clears
the environment variables permanently from your user environment, not
just for the current R session, so they will not come back when you open
a new R session. Windows only applies environment changes to *new*
processes, so close and reopen RStudio afterwards for the change to be
picked up everywhere.

If you would rather change the Git config by hand, you can run this from
a terminal:

    git config --global --unset http.proxy
    git config --global --unset https.proxy

## Git SSL verification

[`check_git_sslverify()`](https://dfe-analytical-services.github.io/dfeR/reference/check_git_sslverify.md)
looks at the `http.sslverify` and `https.sslverify` keys in your global
Git config. A historic DfE setup script set these to `false` to work
around SSL certificate problems on the internal network. That is no
longer necessary, and leaving SSL verification disabled is not something
you want on a long-term basis.

Running `check_git_sslverify(clean = TRUE)` will set both keys back to
`true`.

If you turned SSL verification off recently because you were seeing a
genuine SSL certificate error from R, Git or another tool, turning it
back on will bring that error back. The right next step in that case is
to contact the [Statistics Development
Team](mailto:statistics.development@education.gov.uk) with the command
you were running and the error message you saw, so we can work with the
Network Operations team to unblock the underlying request.

## Global .gitconfig location

[`check_gitconfig_location()`](https://dfe-analytical-services.github.io/dfeR/reference/check_gitconfig_location.md)
reports the path that Git is using for your global config file. It does
not change anything; it only tells you where Git, R and RStudio think
your global config lives.

This check fails when your global `.gitconfig` is inside OneDrive. When
that happens, Git, R and RStudio can disagree about which config file is
in effect, and changes you make in one tool may not be picked up by the
others.

There is no automatic fix for this one because it is a Windows-level
change rather than something R can do for you. The recommended location
is `C:/Users/<username>/.gitconfig`. You will need to move the file
there yourself, and you may also need to set the `HOME` environment
variable on your machine so that everything agrees on where your home
directory is.

## GITHUB_PAT

[`check_github_pat()`](https://dfe-analytical-services.github.io/dfeR/reference/check_github_pat.md)
looks at the `GITHUB_PAT` system environment variable. When this
variable is set, R can fail to install packages from GitHub (including
`dfeR` itself, and `dfeshiny`) with an error like:

    ERROR [curl: (22) The requested URL returned error: 401]

For your safety, the diagnostic only ever shows the last four characters
of the value, and the returned object only contains the masked version.
The raw token never appears in the output, so it is safe to share the
result of
[`diagnostic_test()`](https://dfe-analytical-services.github.io/dfeR/reference/diagnostic_test.md)
with a colleague.

Running `check_github_pat(clean = TRUE)` clears the variable for the
current R session. If the variable comes back the next time you start R,
something on your machine is setting it for you, often a credential
manager or another bit of software, and you will need to find and
disable whichever that is. The function prints a reminder about this
when it clears the variable.

## renv download method (.Renviron)

[`check_renv_download_method()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_download_method.md)
looks for the `RENV_DOWNLOAD_METHOD` entry in your `~/.Renviron` file.
`renv` can download packages using either `curl` or `wininet`, and
`wininet` does not work from within the DfE network. If you see a `renv`
error like “wininet” failing to download packages, this is the setting
to change.

Running `check_renv_download_method(clean = TRUE)` will rewrite
`~/.Renviron` to set `RENV_DOWNLOAD_METHOD="curl"`, removing any
previous assignments of the same variable. If you would rather change
the file yourself, you can open it in RStudio with:

``` r

usethis::edit_r_environ()
```

and add the line:

    RENV_DOWNLOAD_METHOD="curl"

You will need to restart R after editing `.Renviron` for the change to
take effect.

## RENV_DOWNLOAD_FILE_METHOD

[`check_renv_dl_file_method()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_dl_file_method.md)
looks at the `RENV_DOWNLOAD_FILE_METHOD` system environment variable.
The legacy DfE setup script set this to `wininet`, which breaks `renv`
outside the DfE network and is no longer needed.

Running `check_renv_dl_file_method(clean = TRUE)` will remove the
variable. On Windows it clears it both for the current R session and
permanently from your user environment, so it will not come back the
next time you start R. As with the proxy variables, Windows only applies
the change to new processes, so close and reopen RStudio afterwards.

## RTools

[`check_rtools()`](https://dfe-analytical-services.github.io/dfeR/reference/check_rtools.md)
looks for `make` on your `PATH`, which on Windows tells us whether
RTools is installed. Some R packages need to be compiled from source,
and on Windows that requires RTools. A missing `make` will often show up
as a “cannot find make” error during
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
for older package versions that have to be built from source.

This check is reported as `INFO` rather than as a failure when `make` is
missing, because plenty of users do not need to compile packages from
source. If you do need it, the easiest way to get RTools at the DfE is
from the Software Centre. Pick the version that matches your version of
R, install it, then close and reopen RStudio.

If you cannot find RTools in the Software Centre, you can also install
it directly from the [CRAN RTools
page](https://cran.r-project.org/bin/windows/Rtools/).

## .Renviron / .Rprofile location

[`check_renv_rprof_location()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_rprof_location.md)
reports where R will read your `.Renviron` and `.Rprofile` from. R can
read these files from more than one place, so the check lists every
location it consults, in the order R uses them: the `R_ENVIRON_USER` /
`R_PROFILE_USER` environment variable if you have set one, then a copy
in your current working directory, then a copy in your home directory.
Each file that exists is listed, and the one R actually uses is tagged.
It does not change anything; like the gitconfig check, it tells you
where things are.

This check is always `INFO` — it never fails. Its value is in spotting
surprises. The most common one is finding the same file in more than one
place: a stray `.Renviron` or `.Rprofile` sitting in a project folder
will quietly take precedence over the one in your home directory, so
settings you thought you had changed at home are being ignored. If you
see a copy you did not expect, delete the one you do not want.

If any of the listed paths sits inside OneDrive, the check adds a note.
R, RStudio and Git can resolve `~` inconsistently when your home
directory is redirected into OneDrive, so changes you make in one tool
may not be picked up by another. The fix is a Windows-level change
rather than something R can do automatically: set the `HOME` environment
variable explicitly to a path outside OneDrive (for example
`C:/Users/<username>`) and make sure your `.Renviron` and `.Rprofile`
live there.

## Sharing the full output with support

If you have worked through the failed checks and are still stuck, you
can run the diagnostic in `full` mode, which appends a session dump
containing
[`renv::diagnostics()`](https://rstudio.github.io/renv/reference/diagnostics.html),
[`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html) and
[`options()`](https://rdrr.io/r/base/options.html):

``` r

dfeR::diagnostic_test(full = TRUE)
```

The function masks values for any environment variable whose name
contains `TOKEN`, `SECRET`, `KEY`, `PAT`, `PASSWORD` or `CRED`, so your
`GITHUB_PAT` and similar tokens are not shown in full.

### Troubleshooting

A few common issues come up alongside the ones the diagnostic checks
for. These are not currently part of
[`diagnostic_test()`](https://dfe-analytical-services.github.io/dfeR/reference/diagnostic_test.md),
but they are documented in the [Analysts’
Guide](https://dfe-analytical-services.github.io/analysts-guide/learning-development/r.html):

- **Cannot restore from an old `renv.lock`** when several older package
  versions fail to build. Assuming you’re on the right version of R for
  the lockfile, and have ensured RTools is installed as described on
  this page then have a look at the analysts’ guide, which covers using
  [`renv::install()`](https://rstudio.github.io/renv/reference/install.html)
  and
  [`renv::record()`](https://rstudio.github.io/renv/reference/record.html)
  to update individual packages, or
  [`renv::init()`](https://rstudio.github.io/renv/reference/init.html)
  to discard the old lockfile entirely.
- **`shinytest2` errors about an invalid path to Chrome, or about old
  headless mode.** The guide explains setting `CHROMOTE_CHROME` and
  `CHROMOTE_headless` in your `.Renviron`.
- **SSL certificate errors from R or Python.** If a request is being
  blocked by the DfE firewall, contact the [Statistics Development
  Team](mailto:statistics.development@education.gov.uk) with the command
  and error so we can escalate it to the Network Operations team.

If you have run through everything here and are still seeing problems,
please get in touch with the [Statistics Development
Team](mailto:statistics.development@education.gov.uk) with the output of
`diagnostic_test(full = TRUE)` attached.
