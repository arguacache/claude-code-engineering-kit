---
name: fix_duplicate_isbn_import
description: Raw note on a duplicate-ISBN import bug (ISBN-10 vs ISBN-13 forms of the same book).
triggers: [duplicate isbn, import books, isbn-10]
---
# Duplicate ISBN import
The CSV importer inserted both ISBN-10 and ISBN-13 forms of one book. Fixed by normalising
to 13 digits before upsert. TODO: distil into a lesson if it recurs.
