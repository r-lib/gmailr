% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gm_message.R
\name{gm_messages}
\alias{gm_messages}
\title{Get a list of messages}
\usage{
gm_messages(
  search = NULL,
  num_results = NULL,
  label_ids = NULL,
  include_spam_trash = NULL,
  page_token = NULL,
  user_id = "me"
)
}
\arguments{
\item{search}{query to use, same format as gmail search box.}

\item{num_results}{the number of results to return.}

\item{label_ids}{restrict search to given labels}

\item{include_spam_trash}{boolean whether to include the spam and trash folders in the search}

\item{page_token}{retrieve a specific page of results}

\item{user_id}{gmail user_id to access, special value of 'me' indicates the authenticated user.}
}
\description{
Get a list of messages possibly matching a given query string.
}
\examples{
\dontrun{
# Search for R, return 10 results using label 1 including spam and trash folders
my_messages <- gm_messages("R", 10, "label_1", TRUE)
}
}
\references{
\url{https://developers.google.com/gmail/api/reference/rest/v1/users.messages/list}
}
\seealso{
Other message: 
\code{\link{gm_attachment}()},
\code{\link{gm_delete_message}()},
\code{\link{gm_import_message}()},
\code{\link{gm_insert_message}()},
\code{\link{gm_message}()},
\code{\link{gm_modify_message}()},
\code{\link{gm_save_attachments}()},
\code{\link{gm_save_attachment}()},
\code{\link{gm_send_message}()},
\code{\link{gm_trash_message}()},
\code{\link{gm_untrash_message}()}
}
\concept{message}
