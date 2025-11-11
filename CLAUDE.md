# gmailr: Gmail API Interface for R

## Package Overview

gmailr provides R access to the Gmail RESTful API, allowing users to read, send, and manage Gmail messages, threads, drafts, and labels. The package handles OAuth authentication via gargle and constructs MIME messages for email composition.

## Essential Commands

Always use `R --no-save --no-restore-data` when running R from the console.

Always run `air format .` after generating or modifying code. The binary of air is probably not on the PATH but is typically found inside the Air extension used by Positron, e.g. something like `~/.positron/extensions/posit.air-vscode-0.18.0/bundled/bin/air`

## Development Workflow

**Testing**
Place tests in `tests/testthat/test-{name}.R` alongside corresponding source files. Run tests with `devtools::test()` or `devtools::test_file("tests/testthat/test-{name}.R")`. Do NOT use `test_active_file()`. All new code requires accompanying tests.

**Documentation**
After modifying roxygen2 comments, run `devtools::document()` to regenerate documentation. Export all user-facing functions with proper roxygen2 documentation. Add new function topics to the appropriate section in `_pkgdown.yml`. Use sentence case for documentation headings.

**Code Style**
Follow tidyverse style guide conventions. Use `cli::cli_abort()` for error messages with informative formatting. Organize code with "newspaper style"—main logic first, helper functions below.

## Key Technical Details

**Authentication**
OAuth authentication is managed through the gargle package. Users must provide their own OAuth client via `gm_auth_configure()`. Authentication state is maintained across sessions. See `R/gm_auth.R` for implementation details.

**HTTP Requests**
All Gmail API calls go through httr. Request and response handling follows gargle conventions. The most recent API response is available via `gargle::gargle_last_response()` for debugging.

**MIME Message Construction**
Email messages are built using MIME (Multipurpose Internet Mail Extensions) format. The `gm_mime()` function creates a base MIME object, which is then populated using builder functions like `gm_to()`, `gm_subject()`, and `gm_text_body()`. See `R/gm_mime.R` for the implementation.

**Core Resources**
The package organizes around Gmail API resources:
- **Messages** - Individual emails (`R/gm_message.R`)
- **Threads** - Conversation threads (`R/gm_thread.R`)
- **Drafts** - Draft messages (`R/gm_draft.R`)
- **Labels** - Gmail labels/folders (`R/gm_label.R`)
- **Attachments** - Email attachments (in `R/gm_message.R`)

**Testing Considerations**
Tests use recorded HTTP responses to avoid live API calls. Authentication is typically mocked in tests. The `helper.R` file in `tests/testthat/` provides testing utilities.

## Documentation Structure

The `_pkgdown.yml` organizes functions into logical groups:
- Authentication and authorization
- Messages
- Threads
- Drafts
- Labels
- Attachments
- Email creation (MIME)
- Miscellaneous tools

When adding new user-facing functions, ensure they're documented and added to the appropriate section.
