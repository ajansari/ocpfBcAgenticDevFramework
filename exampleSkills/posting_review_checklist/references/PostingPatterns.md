# Posting routine patterns

Read before writing a codeunit that posts a document or a journal. The Standards Guide wins on any conflict.

## Shape

- One posting codeunit per document type. Its `OnRun` takes the document record and calls one `Code()` procedure. Nothing else in the extension writes posted entries.
- Preview and real posting run the same code. Preview goes through the standard `"Gen. Jnl.-Post Preview"` codeunit and an `OnRunPreview` subscriber that calls the same posting codeunit, so what the user previews is what gets posted.
- Validate first, write second. Every `TestField` and every `Error` that can stop the posting runs before the first `Insert` or `Modify`.
- No `Commit` inside the posting codeunit. Preview relies on the whole posting being rolled back; a `Commit` breaks preview and leaves half a posting behind on an error.

## Numbers and entries

- The posted document number comes from the number series through the `NoSeries` codeunit, taken once, and never from a hardcoded format.
- Entry numbers on posted entry tables are taken under `LockTable` (find the last entry, add one) or from an `AutoIncrement` field where the table allows it. Never from an unlocked read.
- Posted entries carry the dimension set ID of the source line, and the global dimension codes beside it.

## Hooks and messages

- Publish `OnBeforePost` and `OnAfterPost` integration events on the posting codeunit, the first with an `IsHandled` parameter.
- Every message the user can see is a label with a `Comment` that explains each placeholder. No concatenated strings.
- On a failure that is not the user's fault, log one telemetry message with a fixed event ID and no personal data.

## Skeleton

```al
codeunit 50100 "Sales Return Post" 
{
    TableNo = "Sales Return Header";

    trigger OnRun()
    begin
        Code(Rec);
    end;

    local procedure Code(var ReturnHeader: Record "Sales Return Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforePost(ReturnHeader, IsHandled);
        if IsHandled then
            exit;

        CheckHeader(ReturnHeader);       // every TestField and Error, nothing written yet
        PostLines(ReturnHeader);         // posted entries, entry numbers under LockTable
        FinalizeHeader(ReturnHeader);    // posted number from NoSeries, delete the open document

        OnAfterPost(ReturnHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePost(var ReturnHeader: Record "Sales Return Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var ReturnHeader: Record "Sales Return Header")
    begin
    end;
}
```

The object ID, the names, and the number range follow the project's Object Register and the Standards Guide, not this skeleton.
