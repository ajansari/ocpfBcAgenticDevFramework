# Posting review checklist

Run every item against each codeunit that posts a document or a journal. A failed item is a finding that names this skill and the item number. These items add to the Standards Guide; none replaces one of its rules.

1. The posting codeunit has one entry point (`OnRun` calling one `Code()` procedure) and no other object in the extension writes posted entries.
2. Preview posting runs the same codeunit as real posting, through the standard preview codeunit and an `OnRunPreview` subscriber.
3. Every `TestField` and every `Error` that can stop the posting runs before the first `Insert` or `Modify`.
4. There is no `Commit` in the posting codeunit or in anything it calls during the posting.
5. The posted document number is taken once, from the number series through the `NoSeries` codeunit.
6. Entry numbers on posted entry tables are taken under `LockTable` or from an `AutoIncrement` field, never from an unlocked read.
7. Posted entries carry the source line's dimension set ID and global dimension codes.
8. The open document is deleted only after its posted copy is written, in the same transaction.
9. `OnBeforePost` (with `IsHandled`) and `OnAfterPost` integration events exist and are raised.
10. Every user-facing message is a label with a `Comment` for each placeholder; no concatenated strings.
11. A failure that is not the user's fault logs one telemetry message with a fixed event ID and no personal data.
12. The test codeunit covers one successful posting, one posting stopped by validation, and one preview that leaves no posted rows behind.
