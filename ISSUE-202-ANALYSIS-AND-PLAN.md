# Issue #202: MIME Structure Bug - Analysis and Fix Plan

## The Problem in Plain English

When you send an email with gmailr that has:
- Both text and HTML body content, AND
- File attachments (like .txt, .pdf, .xlsx, .png)

Some parts of the email disappear:
- With `.txt` attachments → the message body vanishes
- With `.pdf` attachments → the attachment itself vanishes
- Similar problems occur with `.xlsx`, `.png`, and other file types

## Why This Happens

MIME messages need different structures depending on their content:

1. **Simple email (text only)**: Just the text
2. **Multipart/alternative** (text + HTML, no attachments): Both versions wrapped together so email clients can choose which to display
3. **Multipart/mixed** (attachments involved): A container that holds both the message content AND the attachments as separate parts

**The Bug**: gmailr is using `multipart/alternative` when it should be using `multipart/mixed` for emails with attachments.

Think of it like packing boxes:
- ❌ gmailr puts everything in an "alternative" box (designed for holding just text vs HTML)
- ✅ gmailr should put everything in a "mixed" box (designed for holding message + attachments)

## The Correct MIME Structure

For an email with text+HTML body AND attachments, the structure should be:

```
multipart/mixed (the outer container)
├─ multipart/alternative (the message part)
│  ├─ text/plain (plain text version)
│  └─ text/html (HTML version)
├─ application/pdf (attachment)
└─ text/plain (another attachment, if any)
```

## Root Cause in Code

In `as.character.mime()` function in `R/gm_mime.R` (lines 242-299):

**Lines 246-254**: If both text and HTML parts exist, set `content_type = "multipart/alternative"`
```r
if (
  x$attr$content_type %!=%
    "multipart/alternative" &&
    exists_list(x$parts, TEXT_PART) &&
    exists_list(x$parts, HTML_PART)
) {
  x$attr$content_type <- "multipart/alternative"
}
```

**Lines 257-258**: If parts exist, set `content_type = "multipart/mixed"` ONLY if not already set
```r
if (length(x$parts) > 0L) {
  x$attr$content_type <- x$attr$content_type %||% "multipart/mixed"
  # ...
}
```

**The problem**: Step 1 sets the content_type to "multipart/alternative", so step 2's `%||%` operator keeps that value instead of changing it to "multipart/mixed".

## Current gmailr Structure (Wrong)

Currently, gmailr creates a flat structure:

```
multipart/alternative (WRONG - should be multipart/mixed)
├─ text/plain (part 1)
├─ text/html (part 2)
└─ application/pdf (part 3 - attachment)
```

Gmail's API then drops parts because they don't belong in a multipart/alternative container.

---

# Fix Plan

## Proposed Solution

**Approach**: Restructure parts to create nested MIME structure when attachments are present.

Modify `as.character.mime()` to detect when both conditions exist:
1. Text and HTML body parts (stored in indices 1 and 2)
2. Attachments (index 3 and beyond)

When both conditions are met:
1. Create a new nested MIME part of type `multipart/alternative` containing parts 1 and 2
2. Replace the parts list with: `[alternative_wrapper, attachment_1, attachment_2, ...]`
3. Set the outer content_type to `multipart/mixed`

## Implementation Steps

### 1. Modify `as.character.mime()` in R/gm_mime.R

Add logic before line 246 to restructure parts when needed:

```r
as.character.mime <- function(x, newline = "\r\n", ...) {
  # encode headers
  x$header <- lapply(x$header, header_encode)

  # NEW: Check if we need nested structure (text + HTML + attachments)
  has_attachments <- length(x$parts) > 2L
  has_both_bodies <- exists_list(x$parts, TEXT_PART) &&
                     exists_list(x$parts, HTML_PART)

  if (has_both_bodies && has_attachments) {
    # Create nested multipart/alternative for text + HTML
    alternative_part <- gm_mime(
      attr = list(content_type = "multipart/alternative"),
      parts = list(x$parts[[TEXT_PART]], x$parts[[HTML_PART]])
    )

    # Restructure: [alternative_wrapper, attachment1, attachment2, ...]
    attachment_parts <- x$parts[3:length(x$parts)]
    x$parts <- c(list(alternative_part), attachment_parts)

    # Set outer to multipart/mixed
    x$attr$content_type <- "multipart/mixed"
  } else if (has_both_bodies) {
    # No attachments, just text + HTML
    x$attr$content_type <- "multipart/alternative"
  }

  # ... rest of existing logic continues unchanged
}
```

### 2. The existing code after this change

After the restructuring, the existing code (lines 257-298) will handle the nested structure correctly because:
- It already knows how to serialize parts that are themselves mime objects
- The boundary logic works recursively
- The encoding logic applies to each part appropriately

### 3. Remove or update the old text+HTML check

The check at lines 246-254 can be simplified or removed since we're now handling it earlier.

## Testing Strategy

### New Test Cases to Add to tests/testthat/test-gm_mime.R

Create a new test block: `test_that("MIME - Messages with attachments and alternative bodies", { ... })`

**Test 1: Text + HTML + PDF attachment**
```r
msg <- gm_mime() |>
  gm_from("test@example.com") |>
  gm_to("user@example.com") |>
  gm_subject("Test with attachment") |>
  gm_text_body("Plain text version") |>
  gm_html_body("<b>HTML version</b>") |>
  gm_attach_file(test_path("fixtures", "test.pdf"))

msg_chr <- as.character(msg)

# Verify outer is multipart/mixed
expect_match(msg_chr, "Content-Type: multipart/mixed", label = "Outer is multipart/mixed")

# Verify nested multipart/alternative exists
expect_match(msg_chr, "Content-Type: multipart/alternative", label = "Nested alternative exists")

# Verify all parts present
expect_match(msg_chr, "Plain text version", label = "Text body present")
expect_match(msg_chr, "HTML version", label = "HTML body present")
expect_match(msg_chr, "test\\.pdf", label = "Attachment present")
```

**Test 2: Text + HTML + TXT attachment (the original bug report)**
- Same structure as Test 1, use .txt file

**Test 3: Text only + attachment (no HTML)**
```r
msg <- gm_mime() |>
  gm_text_body("Plain text only") |>
  gm_attach_file(test_path("fixtures", "test.pdf"))

msg_chr <- as.character(msg)

# Should be multipart/mixed, NOT alternative
expect_match(msg_chr, "Content-Type: multipart/mixed")
expect_no_match(msg_chr, "multipart/alternative")
```

**Test 4: Regression test - Text + HTML, no attachments**
- Verify this still works as before (existing test at line 138 should cover this)
- Should be `multipart/alternative` (not mixed, not nested)

**Test 5: Multiple attachments**
```r
msg <- gm_mime() |>
  gm_text_body("Text") |>
  gm_html_body("HTML") |>
  gm_attach_file(test_path("fixtures", "file1.pdf")) |>
  gm_attach_file(test_path("fixtures", "file2.png"))

# Verify both attachments present
# Verify correct nesting
```

### Manual Verification Steps

After tests pass:
1. Create and send a test email with the problem combination
2. Check received email in Gmail to confirm all parts visible
3. Test with `gm_send_message()` and `gm_send_draft()`

## Files to Modify

1. **R/gm_mime.R** - Primary change in `as.character.mime()` function
2. **tests/testthat/test-gm_mime.R** - Add comprehensive test coverage

## Edge Cases to Consider

1. **Only HTML + attachment (no text)**: Should be flat `multipart/mixed`, no nesting
2. **Empty parts**: Existing `exists_list()` checks handle this
3. **Manual content_type**: Line 248 check suggests users might set this manually - our new logic should take precedence
4. **Single attachment**: Should work the same as multiple

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing messages without attachments | Only restructure when `length(x$parts) > 2L`; add regression tests |
| Incorrect attachment detection | Clear criterion: parts 3+ are attachments (by design of `gm_attach_file()`) |
| Nested MIME serialization issues | Existing code already handles parts as mime objects; test thoroughly |

## Success Criteria

- [ ] Messages with text+HTML+attachments use `multipart/mixed` outer structure
- [ ] Nested `multipart/alternative` wraps text and HTML when attachments present
- [ ] All existing tests pass (no regressions)
- [ ] New tests cover all reported file types (.txt, .pdf, .xlsx, .png)
- [ ] Manual testing confirms correct display in Gmail
- [ ] Code follows tidyverse style guide
- [ ] Run `devtools::document()` if roxygen comments changed
- [ ] Run `air format .` after code changes
