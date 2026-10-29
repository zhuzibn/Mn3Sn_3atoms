# Project Guidelines & Documentation

All contributors (including AI Agents) must follow these protocols. Record meaningful changes concisely under the relevant sections.

---

## Section 1: Source Code Changes (Changelog)
Update `CHANGELOG.md` for meaningful behavior changes or significant fixes,
following the global changelog policy. Group related edits into one entry.

Include meaningful features, breaking changes, and setup or migration impacts.
Skip typo fixes, formatting, behavior-preserving internal refactors, test-only
changes, and routine documentation cleanup unless project conventions require them.

Append one concise entry per logical change to the bottom of this section.
Use the fields below where useful; omit inapplicable fields:

### [vX.X.X] | YYYY-MM-DD
- **Type:** (feat | fix | change)
- **Description:** Resulting behavior and user impact.
- **Motivation:** Why was this change necessary?
- **Reference:** Optional issue, commit, or detailed project documentation.
- **Test Strategy:** How was this verified?

### [Initial import] | 2026-10-29
- **Type:** feat
- **Description:** Publish the archived Fig. 5 MATLAB source unchanged, with provenance, run instructions, and output protection; retain archived results locally outside Git.
- **Test Strategy:** Verify SHA-256 hashes for all 14 copied originals and review the staged source and documentation; no new simulation run.

---

## Section 2: Error & Solution Log
For significant resolved errors, add a concise note here when useful. Skip
routine transient errors and avoid duplicating Section 1. Keep lengthy
investigations in issues or project documentation and link them here.

### [ERROR-ID] | Short Descriptive Title
- **Context:** Where/when did it happen?
- **Symptoms:** Brief description of the failure.
- **Root Cause:** Brief explanation of the cause.
- **Resolution:** Summary of the fix.
- **Prevention:** How to avoid recurrence, when useful.

---

## Section 3: Workflow for Agents
1. **Analyze** the task or error.
2. **Execute** code changes.
3. **Verify** with tests.
4. Update `CHANGELOG.md` for meaningful behavior changes or significant fixes,
   following the global changelog policy. Group related edits into one entry.
   Use Section 1 for changes and Section 2 for useful significant-error notes.