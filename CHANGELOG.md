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

### [RK4 fourth-stage correction] | 2026-10-29
- **Type:** fix
- **Description:** Use the full third-stage increment for the fourth RK4 stage of all six spins, restoring fourth-order deterministic integration. Preserve physical parameters, output conventions, archived results, and initial-import checksums.
- **Motivation:** The archived half-step fourth stage failed analytical fourth-order convergence checks and changed transient trajectories.
- **Test Strategy:** Actual MATLAB undamped/damped precession tests; nine MATLAB/C trajectory comparisons; 192 diagnostic runs covering Figures 2, 4(a), and 5 at three corrected timesteps plus the archived integrator. Tested switching conclusions survive; the separate Figure 4(b) ferromagnet is excluded at the user’s request.
- **Reference:** [Verification results and reproduction commands](docs/rk4-verification.md).

### 2026-11-03 | Relocation to D:\spin_dynamics
- **Type:** change
- **Description:** Move the checkout and existing local results to `D:\spin_dynamics\Mn3Sn_3atoms`; retain its sibling relationship with `Mn3Sn` and document the new location.
- **Test Strategy:** Verify every relocated file with SHA-256 and preserve the Git branch, HEAD and pre-existing working-tree changes before updating path documentation. No numerical source changes or simulations.

### 2026-11-03 | Relocation into Git_control
- **Type:** change
- **Description:** Move the checkout and existing local results to `D:\Git_control\spin_dynamics\Mn3Sn_3atoms`, preserving the sibling relationship with `Mn3Sn` and updating the documented checkout path.
- **Test Strategy:** Compare branch, HEAD, status and binary diffs with the pre-move snapshot before path edits; check documentation diffs. No numerical source changes or simulations.


### [CQ-01–CQ-05 deterministic API and regression] | 2026-11-20
- **Type:** feat
- **Description:** Add validated `mn3sn_default_config`/`mn3sn_run` inputs, schema-1 results with actual configuration/source/runtime records and physical plus legacy clocks, fresh output directories and protected accepted references. `main` uses the same API; new MAT files contain `result` instead of the whole workspace, and legacy text is written once per run.
- **Test Strategy:** Explicitly accepted 11-case baseline captured twice; all ten short cases and the full 5 ns default preserve every saved spin sample exactly. Focused input/output/path/comparator failure checks, analytical RK4 precession and nine MATLAB/C comparisons pass. Preserve physics, defaults, archived data and original checksums.
- **Reference:** [Commands, measurements, compatibility and scientific limits](docs/code-quality-verification.md).

### [Retained trajectory storage] | 2026-11-20
- **Type:** change
- **Description:** Retain requested six-spin samples during integration and remove unused diagnostic histories, reducing measured default state/diagnostic storage from 312 MB to 2.88 MB. Output samples, clocks and text remain unchanged.
- **Test Strategy:** All 11 accepted cases, five dense/subsample controls, analytical convergence and nine MATLAB/C comparisons pass; accepted data and original import checksums are preserved.
- **Reference:** [Storage verification and measurement scope](docs/retained-storage-verification.md).

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
