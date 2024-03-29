% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gmailr-package.R
\name{gmailr-configuration}
\alias{gmailr-configuration}
\alias{gm_default_email}
\alias{gm_default_oauth_client}
\title{Configuring gmailr}
\usage{
gm_default_email()

gm_default_oauth_client()
}
\description{
gmailr can be configured with various environment variables, which are
accessed through wrapper functions that provide some additional smarts.
}
\section{\code{gm_default_email()}}{

\code{gm_default_email()} returns the environment variable \code{GMAILR_EMAIL}, if it
exists, and \code{\link[gargle:gargle_options]{gargle::gargle_oauth_email()}}, otherwise.
}

\section{\code{gm_default_oauth_client()}}{

\code{gm_default_oauth_client()} consults a specific set of locations, looking for
the filepath for the JSON file that represents an OAuth client. This file can
be downloaded from the APIs & Services section of the Google Cloud console
\url{https://console.cloud.google.com}). The search unfolds like so:
\itemize{
\item \code{GMAILR_OAUTH_CLIENT} environment variable: If defined, it is assumed to be
the path to the target JSON file.
\item A \code{.json} file found in the directory returned by
\code{rappdirs::user_data_dir("gmailr")}, whose filename uniquely matches the
regular expression \code{"client_secret.+[.]json$"}.
\item \code{GMAILR_APP} environment variable: This is supported for backwards
compatibility, but it is preferable to store the JSON below
\code{rappdirs::user_data_dir("gmailr")} or to store the path in the
\code{GMAILR_OAUTH_CLIENT} environment variable.
}

Here's an inspirational snippet to move the JSON file you downloaded into the
right place for auto-discovery by \code{gm_auth_configure()}:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{path_old <- "~/Downloads/client_secret_123-abc.apps.googleusercontent.com.json"
d <- fs::dir_create(rappdirs::user_data_dir("gmailr"), recurse = TRUE)
fs::file_move(path_old, d)
}\if{html}{\out{</div>}}
}

\examples{
gm_default_email()

withr::with_envvar(
  c(GMAILR_EMAIL = "jenny@example.com"),
  gm_default_email()
)

gm_default_oauth_client()

withr::with_envvar(
  c(GMAILR_OAUTH_CLIENT = "path/to/my-client.json"),
  gm_default_oauth_client()
)
}
\seealso{
Since gmailr uses the gargle package to handle auth, gargle's
configuration is also relevant, which is mostly accomplished through
\link[gargle:gargle_options]{options and associated accessor functions}.

Other auth functions: 
\code{\link{gm_auth_configure}()},
\code{\link{gm_auth}()},
\code{\link{gm_deauth}()},
\code{\link{gm_scopes}()}
}
\concept{auth functions}
