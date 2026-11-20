# CQ-01–CQ-05 implementation and reference review

The user approved the CQ-01–CQ-05 plan and then explicitly accepted the
verified 11-case baseline on 2026-11-20: **“Accept this baseline and continue.”**
The canonical API, protected schema-1 results, complete candidate comparator and
focused checks are implemented and verified. All eleven migrated cases match
the accepted trajectories exactly, including the full 5 ns default run.
No physics, numerical defaults, accepted reference bytes, or original archive
has been changed by this migration. No commit or push was made.

## Model and preserved evidence

The unchanged model is Class 5: fixed-length LLGS for a noncollinear
three-sublattice uniform Mn3Sn model, retaining all six stored vectors and the
decoupled spectator triplet. The [original audit](fig2-4-original-audit.md) and
[RK4 report](rk4-verification.md) retain physical conventions and previous
source/PDF evidence. This software task does not revalidate their material
interpretation or claim a new publication reproduction.

The adopted specification below records the equations files consulted: `spintronic_methods.tex`,
`symbols.tex`, `sections/material_parameters.tex`,
`sections/macrospin_effective_field.tex`, and `sections/llg_equation.tex`
(`eq:llg-gilbert`, `eq:ll-with-flt`). Its R1 limitation remains: exact physical
source details were inherited from earlier audits rather than rechecked in the
separately protected source-paper library. The local Mn3Sn topic synthesis and
EE237 week15a presentation record supplied scope/context evidence only.

## Reference capture design

`benchmark/regression_cases.m` declares ten quick cases and one extended case.
`benchmark/prepare_reference.m` snapshots unchanged sources, verifies historical
initialization reconstruction and seeds, and captures each case twice in separate
directories. It checks the actual executing copies before and after each run.
Preparation and verification enforce a complete fixed inventory and exact helper
source identity. No command accepts a reference, overwrites an existing proposal,
or writes to `benchmark/baseline`.

The extended case executes the actual unchanged `main.m` with its 5 ns runtime,
5 fs timestep, 250 Oe field, current density `5e10 A/m²`, and 1–4 ns drive.
The pulse-edge case uses a 20 ps runtime and 5–15 ps drive. Other quick cases
reuse the historical pilot and eight replay inputs. Full arrays retain the
legacy sampling and clocks; physical clocks are stored alongside them without
altering integration.

The verification checks every sample of all six spins, both clocks, initial
state, actual inputs, raw norms, RNG state, and fresh hashes of text outputs.
Historical cases also compare against both their MATLAB and C CSVs. The acceptance record chooses repeat-1; repeat-2 demonstrates repeatability
and is not a second ambiguous baseline.

## Historical reference-capture commands and environment

Repository HEAD: `c141345441feacac73047ae8f811048b2494d824` on `main`.
README/CHANGELOG relocation edits and the previously reviewed plan/report edits
were present before this implementation. No branch, commit or push operation ran.

MATLAB startup probe:

```bash
matlab -wait -batch "disp(version); disp(computer); disp(version('-release')); disp(usejava('jvm'));"
```

Observed: MATLAB `24.2.0.2740171 (R2024b) Update 1`, `PCWIN64`, Java available.
The host reports `Intel64 Family 6 Model 154 Stepping 3, GenuineIntel` and
20 logical processors. Both repetitions used this same installed runtime.
The WSL wrapper launches the installed Windows MATLAB executable. No dependency
installation, GPU execution or network access was needed.

The historical proposal directory is
`D:\Git_control\spin_dynamics\Mn3Sn_3atoms\.sisyphus\cq-reference-proposal-20261120-v3`.
From the repository root, these commands started the two isolated captures:

```bash
matlab -wait -batch "addpath('benchmark'); prepare_reference(fullfile(pwd,'.sisyphus','cq-reference-proposal-20261120-v3'),'prepare'); prepare_reference(fullfile(pwd,'.sisyphus','cq-reference-proposal-20261120-v3'),'capture',1);"
matlab -wait -batch "addpath('benchmark'); prepare_reference(fullfile(pwd,'.sisyphus','cq-reference-proposal-20261120-v3'),'capture',2);"
```

These commands describe the executed pre-migration capture, not a routine
command for the migrated source. The capture tool intentionally requires the
original source hashes. The two repetitions own separate folders and refuse
existing destinations. Earlier
`v1` and `v2` preparation/debug attempts are retained under `.sisyphus` and are
excluded from the reference selection.

Aggregate verification and the disposable failure checks ran successfully:

```bash
matlab -wait -batch "addpath('benchmark'); report=prepare_reference(fullfile(pwd,'.sisyphus','cq-reference-proposal-20261120-v3'),'verify'); disp(struct2table(report.cases));"
matlab -wait -batch "addpath('benchmark'); checks=check_reference_capture(fullfile(pwd,'.sisyphus','cq-reference-proposal-20261120-v3')); fid=fopen(fullfile(pwd,'.sisyphus','cq-v3-mutation-checks.json'),'w'); fprintf(fid,'%s\n',jsonencode(struct('passed',true,'checks',{checks},'matlab',version),PrettyPrint=true)); fclose(fid);"
```

The verification command writes its manifest once and refuses to replace it.
The second command's evidence file is the recorded one-time run; use a fresh
evidence filename when independently rerunning the failure checks.

## Reference-capture results — 2026-11-20

All 11 cases completed twice: 22 actual MATLAB trajectories. Each quick case
retains 80 samples and the full-default case retains 20,000. Every sample contains
all six spins. The maximum component difference between repetitions is **zero**
for every case; both clocks and every per-run text file also agree.

| Gate | Measured result | Acceptance |
|---|---:|---:|
| Repeatability, all trajectory components | 0 | `<1e-10` |
| Maximum raw-array unit-norm error | `2.220446049250313e-16` | `<1e-12` |
| Nine new captures vs historical MATLAB CSVs | `5.551115123125783e-16` | `<1e-10` |
| Nine new captures vs historical C CSVs | `8.892239541634196e-12` | `<1e-10` |
| Physical/legacy clock checks | All pass | 32 ulps at maximum time; initial zero exact |
| Full-default elapsed time | 437.119 s / 447.482 s | Recorded, not a performance gate |
| Deterministic RNG state before/after | Identical | No random draws |
| Protection and deliberate failure checks | 15 pass | Required errors raised; no verified manifest on failure |

The 15 checks reject existing proposal/repetition destinations and the accepted
baseline location, missing/changed case inventories, missing fixture inventory,
changed executing source or text bytes, an interior spin rotation preserving
norm/endpoints, wrong physical or legacy clocks, NaN, wrong initial state, a norm
defect and incompatible stored inputs. Mutated fixtures remain in separate ignored
test directories. SHA-256 hashes of all **382 original proposal files** matched
before and after these checks; the proposed references were not edited.

Before production migration, the import-preservation command passed for all 11 unchanged distributed
files (ten MATLAB files plus PBSScript). All 11 root MATLAB source files,
including the intentionally corrected integrator, match the historical corrected
source snapshot. No simulation ran in the repository root or original archive.

A read-only independent reviewer checked the capture code and prepared v3 files.
All 11 production MATLAB files matched historical source hashes, all nine
historical initializers matched their prescribed reconstruction, all 52 prepared
artifact hashes matched, and both capture helpers matched their snapshots.
The reviewer ran no MATLAB simulation and made no file changes. The numerical
evidence above comes from the actual captures and verification, not reviewer agreement.

## Accepted baseline ownership

The historical [benchmark/reference_proposal.json](../benchmark/reference_proposal.json)
is intentionally unchanged. Its status is `proposed-awaiting-user-acceptance`, `accepted` is false, and
`acceptance_record` is null. Manifest SHA-256:

```text
1c7314aa1e4fa163890daf42d7a7a5bf2b189af3ea1357512c7feb53821073c3
```

The manifest selects **75 files, 5,463,738 bytes**: eleven repeat-1 compact MAT
references, eleven legacy text references, and the prepared source/fixture/tool
snapshot with its preparation record. Every file has an explicit source path,
proposed baseline path, size and SHA-256. It also records the complete case
inventory, runtime, commands and verification-evidence hashes.

After the explicit user acceptance, exactly those 75 files were copied without
regeneration to tracked `benchmark/baseline/` and all hashes verified.
[baseline_manifest.json](../benchmark/baseline_manifest.json) is the current
accepted record: it retains the proposal digest and user acceptance alongside
the artifact inventory. Repeat-2, repeated sources, raw legacy workspaces, failed
proposals and disposable mutation fixtures remain excluded. The accepted files
are self-contained for routine regression; the ignored proposal is audit evidence,
not a required external data dependency.

The input source files and paper-derived assumptions remain those specified
below and in the accepted source snapshot. Reference agreement detects behavior changes; it does not settle R1,
validate optional thermal/STT/FLT modes, or rerun the complete published figures.

## Implemented scope and verification

The source audit confirmed the shared matrix's broad gaps, but found its apparent
pulse-validation claim referred to a commented example. Historical MATLAB/C CSVs
were present without an accepted baseline; no routine command was allowed to
bootstrap one. Actual source inspection, two repeated captures and explicit
acceptance preceded production refactoring. The parent matrix remains unchanged
because it belongs to another repository; this report supplies local adoption evidence.

| Feature | Implemented boundary / evidence |
|---|---|
| CQ-01 | Ten quick cases and one full-default case; immutable 75-file reference manifest; all-six-spin arrays, clocks, exact inputs, raw invariants and malformed-data errors. |
| CQ-02 | Flat factory/validator plus callable runner; main uses the same defaults; field switches passed explicitly; unsupported physics rejected. |
| CQ-03 | Schema-1 result, physical and legacy clocks, effective constants/inputs, source hashes/Git probes, environment/RNG metadata; exact MAT round trip. |
| CQ-04 | Fresh output reservation, baseline protection through real filesystem paths including Windows junctions, once-per-run text writing; verification outputs also reject reuse. |
| CQ-05 | API/error/clock/path/comparator tests, actual MATLAB analytical precession and nine fixed MATLAB/C checks independent of the 192-case figure sweep. |

Production edits are confined to new configuration/validation/runner/hash/path
helpers, the thin `main` caller, explicit switches in `field_eta` and four RK4
calls, and replacing RK4's file writes with collection of the identical text rows.
No field/RHS/integration arithmetic was reordered. `LLG_solver`, constants,
switch defaults, pulse helpers and the C diagnostic remain unchanged.
The nine unused initialization-only fields omitted from effective inputs are
`Dx,Dy,Dz,IMAPMA,enable_Hk_x,inita_phi,inita_theta,initb_phi,initb_thetb`;
exact initial vectors replace the angle bookkeeping. All consumed inputs are
compared explicitly against the accepted legacy records.

An independent read-only reviewer checked each gate. Stage-4 findings led to
unique/required reference-path validation, sampling/unit metadata assertions and
mode-specific protected verification CSVs. An actual Windows junction test
showed `java.io.File.getCanonicalPath` alone did not resolve its target; the
runner now resolves existing ancestors using NIO `toRealPath`. The test checks
resolution read-only before attempting a forbidden destination. No accepted
file was written while testing the guard.

Executed from the repository root (Windows MATLAB via the installed WSL wrapper):

```bash
matlab -wait -batch "addpath('benchmark'); candidate=run_regression(fullfile(pwd,'.sisyphus','cq-candidate-20261120-v1'),'quick'); report=compare_to_baseline(candidate,'quick');"
matlab -wait -batch "addpath('tests','benchmark'); report=run_all_tests(fullfile(pwd,'.sisyphus','cq-candidate-20261120-v1'));"
python3 verification/run_checks.py prepare --out .sisyphus/cq-focused-20261120-v1
python3 verification/run_checks.py accepted-replays --out .sisyphus/cq-focused-20261120-v1
matlab -wait -batch "addpath('verification'); check_matlab(fullfile(pwd,'.sisyphus','cq-focused-20261120-v1'),'full');"
matlab -wait -batch "addpath('benchmark'); candidate=run_regression(fullfile(pwd,'.sisyphus','cq-default-20261120-v1'),'extended'); report=compare_to_baseline(candidate,'extended'); save(fullfile(candidate,'comparison.mat'),'report');"
```

These are recorded execution paths; use unused names when repeating candidate
runs. The extended command was preceded by a successful actual-junction guard
assertion. Some sandboxed WSL starts failed with `UtilBindVsockAnyPort` before
MATLAB began; the authorized Windows-launcher exception was used for final checks.
This was a launch restriction, not a numerical test failure.

| Check | Actual result |
|---|---|
| Old/new initialization | All factory defaults, six initial vectors and consumed inputs identical. |
| Ten quick MATLAB candidates | Every saved spin component differs by **0**; both clocks and exact text bytes pass. |
| Interface/output/comparator tests | 26 invalid inputs fail before output creation; unknown/missing fields fail; round trip, clocks, caller independence, DLT-off equivalence, unique automatic outputs, source identity, shadow rejection, existing-output and actual-junction guards pass. |
| Deliberate candidate defects | 13 corruptions fail, including interior-only rotation, both clocks, config, shape, NaN, norm, order, initial state, text, solver metadata and units; missing inventory fails. |
| Reference defects | Damaged MAT bytes and a duplicated manifest entry hiding an unhashed case fail using disposable copies. |
| README 20 ps example | Executed; all spin arrays equal the accepted pulse-edge case exactly. |
| Corrected precession order, damping 0 | 3.9961298, 3.9990336, 3.9997583. |
| Corrected precession order, damping 0.1 | 3.9977542, 3.9998405, 4.0001615. |
| Archived negative controls | Orders 1.9975–1.9998 (undamped), 1.0347–1.1222 (damped); correctly fail fourth-order gate. |
| Nine MATLAB/C checks | All pass, including both clocks; maximum spin error `8.8922395416342215e-12`. |
| Full-default candidate | All 20,000 samples of all six spins differ by **0**; both clocks and text pass; raw norm error `2.2204460492503131e-16`. Elapsed 668.536897 s, with other checks running concurrently; not a performance comparison. |

Focused evidence is in `.sisyphus/cq-focused-20261120-v1/matlab-checks.json`.
Final focused tests passed in
`.sisyphus/cq-tests-18fa2206-e471-46bb-9d00-3e3682395ceb/test-report.json`.
Both production and candidate runners reject a caller-directory shadow of the
path resolver before it executes or writes. Relative destinations resolve from
MATLAB's current directory. Existing-report and partial-CSV reuse tests also
raised errors and left the existing trajectory hash unchanged; the latter used
`.sisyphus/cq-focused-partial-20261120-v1`, with no report copied into it. Candidate MAT files
store their own actual source hashes and run environment; source revisions during
later test/documentation work are not retroactively assigned to earlier runs.
Numerical acceptance remains component error `<1e-10`, raw norm error `<1e-12`,
clock error at most 32 ulps at maximum time, and exact initial zero. No tolerance
was loosened. The full 192-case figure sweep was not repeated, and no new claims
are made about temperature, finite FLT/STT, intertriplet coupling, spatial domains,
Figure 4(b), or the exact physical source details still marked R1 below.

## Adopted scientific specification and evidence boundary

The following model conventions and source locators were approved before edits.
They preserve code behavior and the earlier audits; R1 prevents treating inherited
exact physical details as freshly source-verified material claims.

**Class 5**, already defined in the previous audit: spatially uniform,
noncollinear, three-sublattice Mn3Sn macrospin dynamics, fixed-length LLGS.
The local synthesis supports the three-sublattice/configuration-II scope [1,
“Scope and evidence base”, “Comparison”]; the historical audit attributes the
model to [2, Sec. II]. This is neither a two-collinear-sublattice model nor a
crystallographic lattice builder. The Class-5 degrees of freedom are explicitly
approved explicitly rather than inferred from the folder name.

Six dimensionless Cartesian unit vectors are stored. Columns 1–3 represent the
active triplet; columns 4–6 remain an exchange-coupled spectator triplet with
`Hex_1=0` between triplets. `Fe`/`Gd` are legacy variable names, not a claim of
Fe/Gd material species. All six vectors remain in regression and output.
Electronic structure, domains, spatial nucleation, and crystal boundaries are
outside this classical uniform model. Finite states and unit norms are invariants.


## State Variables, Geometry, and Boundaries

Use `initial_m` as a real finite `6 x 3` array in order
`[ma1; ma2; ma3; mb1; mb2; mb3]`, Cartesian order `[x,y,z]`. Keep the existing
`N x 6` arrays `mmx`, `mmy`, `mmz`; do not drop spectator spins or permute `mb2/mb3`.
The active model uses the yz plane and +x DLT polarization [1, “Comparison”;
3, slides 25–27, qualitative geometry only]. Initial vectors and coefficients
are preserved implementation inputs, not reconstructed from a crystallographic
interpretation.

Default angular construction uses `theta_a=210°`, `theta_b=150°`, both azimuths
`90°`; active offsets are `0,120,240°`, spectator storage offsets `0,240,120°`.
Copy the exact existing trigonometric evaluation, including tiny x components.
The new API rejects nonunit/zero vectors rather than silently renormalizing its
inputs; per-step normalization remains unchanged.

`LFL=WFL=50 nm`, `tFL=30 nm`; thickness enters SOT. Other geometry constants are
listed below. No mesh, neighbor list, periodic/open boundary, structure table,
or atomistic illustration is applicable. Signed mean-spin angle may be used in
checks, but is undefined at the perfectly compensated initial seed. Do not
replace raw-spin comparisons with that angle or change legacy plotting.

## Hamiltonian

No Hamiltonian implementation change. For the selected default scope, preserve
the code-equivalent energy in joules, with each triangle pair counted once:

$$
E=J\sum_{(i,j)\in\{(1,2),(2,3),(3,1)\}}
(\mathbf a_i\cdot\mathbf a_j+\mathbf b_i\cdot\mathbf b_j)
+D\hat{\mathbf x}\cdot(\mathbf a_1\times\mathbf a_2+
\mathbf a_2\times\mathbf a_3+\mathbf a_3\times\mathbf a_1)
-K\sum_{i=1}^{3}(\mathbf n_i\cdot\mathbf a_i)^2
-m_s\sum_{i=1}^{3}\mathbf B_{\rm ext}\cdot(\mathbf a_i+\mathbf b_i).
$$

Here `J=ms*Hex_2`, `ms=3*mub`, and the easy-axis angles from +z toward +y
are `30°,270°,150°`. The spectator has no anisotropy or DMI in the implemented
path; intertriplet coupling and demagnetization are zero. This expression is an
unchanged code/audit convention, historically associated with [2, Sec. II].
**REFERENCE MISSING (R1)** for fresh qualifying verification of the precise
pair multiplicity, spectator interpretation, axes, and coefficients; see risks.
Do not infer physical layer topology from these bookkeeping vectors.
SOT is nonconservative and excluded from this energy.

## Parameters and Evidence

All numbers below are the inspected current defaults. Preserve exact literals
and derivation order; do not replace `Hex_2` by a recomputed rounded energy ratio.
Scientific source-check gaps do not authorize changes to these values.

| Inputs/constants | Default and units | Role / evidence |
|---|---|---|
| `Ms_Fe`, `Ms_Gd`, `alp` | 441.85 emu/cm³ each; 0.003 | SOT conversion/damping; historical [2, Sec. II], R1 for fresh exact check |
| `Hex_1`, `Hex_2` | 0, 100.812 T | Intertriplet/triangle exchange; code convention, R1 |
| `hk_constant`, `hk6` | `0.196e-3*ele` J; `2*hk_constant/(3*mub)` T | Active anisotropy; historical [2, Sec. II], R1 |
| `DMI_constant`, `DMI` | `0.833e-3*ele` J; `DMI_constant/(3*mub)` T | Active DMI; historical [2, Sec. II], R1 |
| `LFL,WFL,tFL` | 50,50,30 nm | Volume/thickness; 30 nm historically [2]; lateral dimensions code-only, R1 |
| `LHM,WHM,tHM,lambdaSF` | `1.1*LFL`, `1.1*WFL`, 7 nm, 5 nm | Retained legacy inputs; no effect on selected deterministic SOT expression, R1 |
| `Hext` | `[0,0.0250,0]` T = +250 Oe | Current default Fig. 5 case; not the +100 Oe representative case in [1] |
| `jc_SOT`, `thetaSH`, `polSOTD_Fe/Gd` | `50e9` A/m², 0.06, `[1,0,0]` / `[0,0,0]` | DLT; representative current/geometry supported by [1]; exact coefficient R1 |
| `SOT_DLT`, `SOT_FLT`, `jc_SOT2`, `facFLT_SHE` | 1, 1, 0 A/m², 1 | FLT flag is **on**, but amplitude is zero. Preserve this distinction. |
| `polSOTF_Fe/Gd` | `[0,0,-1]` / `[-1,0,0]` | Inactive FLT legacy inputs; R1, no new physical claim |
| `STT_DLT`, `STT_FLT`, `jc_STT`, `facFLT_STT` | 0, 0, 0 A/m², 0 | Inactive STT; `PolFL=0.4`, `PolSTT=mmmPL=[0,0,1]` retained |
| `Hk_Fe/Gd_{x,y,z}`, `Demag_`, `K12Dipole` | All zero; tensors `3 x 3` | Inactive legacy fields; `enable_Hk_x=1` still produces zero |
| `thermalnois`, `TT`, `dipolee` | 0, 1000 K, 0 | Noise disabled despite nonzero temperature input; dipole disabled |
| `IMAPMA`, `dimensionlessLLG` | 2, 0 | Legacy mode, dimensional RK4 path |
| `runtime`, `tstep`, `savestep` | 5 ns, 5 fs, 50 | Preserve step count and 0.25 ps sampling; timestep historically [2], R1 |
| `starttime`, `endtime`, `pulsewidth`, `risetime`, `downtime` | 1 ns, 5 ns, 3 ns, 0, 0 | Current pulse; field start/end/width derived identically |
| Initial angles/vectors | As previous section | Exact implementation inputs; no replacement seed |
| `gam` | `1.760859644e11` rad/(s T) | Immutable `constantfile.m` value |
| `ele`, `mub`, `hbar` | `1.602e-19` C, `9.274e-24` J/T, `6.58211951440e-16` eV s | Immutable legacy constants; numeric `hbar` is hbar/e in torque SI conversion |
| `mu_0`, `kb` | `1.25663706143592e-6` T m/A; `1.38064852e-23` J/K | Immutable constants; inactive in selected thermal-free RHS |

The adopted public configuration is a flat struct using recognizable legacy names,
plus `initial_m` and `solver='rk4'`; no recursive override framework. The factory
returns complete inputs, the caller edits named fields, and validation rejects
unknown or missing fields. Keep immutable constants and derived values separate
from editable inputs. `conf_file.m` can remain the single source of switch
defaults, read inside the factory's private workspace; the run never reloads it.
`constantfile.m` remains the constant source. Derived pulse arrays, `totstep`,
`hk6`, `DMI`, conversion factors, and exact initial vectors belong in the recorded
effective configuration. Fixed inactive legacy values are recorded, not exposed
as misleading supported physical options.

The first supported scope is deterministic dimensional RK4 with `Hex_1=0`,
zero demagnetization/dipole, no STT, and zero FLT amplitude. Permit DLT on/off,
material coefficients of the active terms, field/current sign and amplitude,
timing, and valid six-spin initial inputs. Preserve all defaults. Reject enabling
noise, STT, finite FLT, intertriplet coupling, dimensionless mode, or another solver
at API entry; do not silently ignore or reinterpret them. This declares a tested
support boundary and does not alter the archived formulas for those paths.

## Effective Fields and Units Check

Preserve the unchanged code convention `B_i=-(1/ms)*dE/dm_i`, in tesla;
`J/ms=Hex_2`, `2K/ms=hk6`, `D/ms=DMI`. For cyclic active indices `(i,j,k)`:

$$
\mathbf B_i=-H_{\rm ex,2}(\mathbf a_j+\mathbf a_k)
+h_{k6}(\mathbf n_i\cdot\mathbf a_i)\mathbf n_i
+D_{\rm code}\hat{\mathbf x}\times(\mathbf a_j-\mathbf a_k)
+\mathbf B_{\rm ext}.
$$

Spectator fields retain exchange and applied field only. Since `J/(J/T)=T`,
no additional `mu_0` belongs in these moment-based fields. The SOT amplitude is
`b=hbar*thetaSH*jc_SOT/(2*tFL*(Ms*1e3))` T with the legacy constant convention;
do not divide by `ele` a second time. Fields already in tesla are not converted
again. These are implementation/units checks, not newly established material
facts; R1 applies to precise physical attribution.

Consulted equations repository files: `AGENTS.md`, README,
`spintronic_methods.tex`, `symbols.tex` (constant/field conventions),
`sections/material_parameters.tex` (`tab:mn3sn-parameters`),
`sections/macrospin_effective_field.tex` (`eq:macrospin-effective-field`), and
`sections/llg_equation.tex` (`eq:llg-gilbert`, `eq:ll-with-flt`). The energy-density
formula requires its own magnetization/volume factors; do not substitute it for
the existing moment-based derivative. These files guide convention checking,
not independent qualifying material evidence.

## Dynamical Equation and Nonconservative Torques

Keep the explicit implemented RHS, with the scaling still applied exactly once
by RK4 and `p=+x` for active DLT, `p=0` for the spectator:

$$
\dot{\mathbf m}=\frac{\gamma}{1+\alpha^2}
[-\mathbf m\times\mathbf B-\alpha\mathbf m\times(\mathbf m\times\mathbf B)
-b\mathbf m\times(\mathbf m\times\mathbf p)+\alpha b\mathbf m\times\mathbf p].
$$

This matches the DLT part of `eq:ll-with-flt` and the historical [2] audit.
`LLG_solver.m` retains all existing STT/FLT damping cross terms byte-for-byte;
the selected run gives them zero amplitudes. No LLGS conversion, LLB, stochastic
interpretation change, or new torque was introduced. Noise-enabled numerical accuracy
and interstage random draws remain outside the accepted scope.

## Initial Conditions, Solver, and Outputs

Retain corrected coupled RK4, full `k3*dt` fourth stage, per-step normalization,
and drive values frozen at the current step for all four stages. Let
`N=round(runtime/tstep)`. Preserve `N-1` updates, sample indices
`1:savestep:N`, and the legacy `linspace(0,runtime,N)` labels. Do not insert a
new final sample or perform an extra step.

The new result explicitly distinguishes:

- `time_s=(sample_index-1)*tstep`: physical time of each saved spin state;
- `legacy_tt`: the original sampled `linspace` labels, retained unchanged;
- requested end, actual integrated end `(N-1)*tstep`, and actual sampled end.

Legacy text records are a separate sampling contract: at `ct1=q`, the row
contains state `q+1` and old label `t(q)*1e12`. Its physical time is `q*tstep`.
Retain existing seven-column formatting/content in a per-run `result.txt`;
record this offset and text-sampling stride in the result. Never equate text
rows with the MAT samples or silently relabel old files.

Adopted API: `cfg=mn3sn_default_config(); result=mn3sn_run(cfg,output_dir)`.
Omitting `output_dir` allocates a fresh directory under ignored `.sisyphus/runs/`;
an explicit destination must not exist. No overwrite mode is needed in this
first version. Validate inputs and reserve the destination before integration.
`main.m` calls this API and exposes `tt=legacy_tt`, `mmx`, `mmy`, `mmz` as small
compatibility aliases for existing workspace plotting; it has no second parameter
block or save path. Loading new files uses `load(path,'result')`, an intentional
documented output-interface change.

`<run>/final.mat` contains only a versioned `result` (schema 1), with configuration,
effective constants/derived inputs, exact initial state, units/order, complete
sampled arrays, both clocks, solver/sampling policy, output paths and limitations.
Capture UTC creation time, Git HEAD/branch/status with actual probe outcome,
resolved source paths and SHA-256 hashes, MATLAB version/platform/toolboxes and
available CPU information. Missing metadata receives a reason, never an invented
“Git unavailable” value. Record RNG state before/after and `thermalnois=0`;
assert deterministic execution does not draw randomness. This is not a claim of
thermal reproducibility. No full workspace, source-library data, or secrets are saved.


## References

[1] Local reviewed-paper synthesis:
[/mnt/d/Git_control/paper-knowledge-base/topics/mn3sn-spin-orbit-torque-switching.md](/mnt/d/Git_control/paper-knowledge-base/topics/mn3sn-spin-orbit-torque-switching.md),
“Scope and evidence base”, “Comparison”, and “Shared mechanism”. Read completely
for this plan. Supports model scope/qualitative geometry and representative drive;
it does not supply all exact coefficient, axis or pair-counting details.

[2] Zhengde Xu, Xue Zhang, Yixiao Qiao, Gengchiau Liang, Shuyuan Shi*,
Zhifeng Zhu†, Deterministic spin-orbit torque switching including the interplay
between spin polarization and kagome plane in Mn3Sn, Physical Review B
**109**, 134433 (2024). DOI:
[10.1103/PhysRevB.109.134433](https://doi.org/10.1103/PhysRevB.109.134433).
Paper KB ID: `AFM/2024-Deterministic spin-orbit torque switching including the interplay between spin-PRB-zhengde Xu`.
`papers.jsonl` and `paper-catalog.md` were inspected; indexed status is synthesized.
The per-paper summary, extraction and PDF point into the separately protected
OneDrive paper library and were **not reopened in this turn**. Historical
[original audit](fig2-4-original-audit.md) and
[RK4 report](rk4-verification.md) record their earlier summary/PDF inspection
(Sec. II, Figs. 1–5/Table I). Inherited exact claims above are labeled R1 rather
than misrepresented as fresh primary-source verification.

[3] Presentation record:
[/mnt/c/Users/zzf-m/OneDrive/presentation-knowledge/notes/ee237/week15a-afm/summary.md](/mnt/c/Users/zzf-m/OneDrive/presentation-knowledge/notes/ee237/week15a-afm/summary.md)
and `slides.md`, slides 25–27. Reviewed summary read completely and relevant
extraction inspected; original PPTX not opened. Slide 25 cites [2]; slide 27
supplies qualitative configuration-II context. No quantitative parameters were
inferred from its missing image content or unrelated cited works.

Software criteria and evidence: installed skill's `code-quality.md`,
`plan-template.md`, `verification-and-evidence.md`, `macrospin.md`; shared matrix;
active source/reports; selective ODE interface examples described above. These
are implementation/convention evidence, not replacements for scientific sources.


- **R1 — REFERENCE MISSING for fresh qualifying verification of exact physical
  details:** exact material/constant values, pair counting, easy axes, spectator
  physical interpretation and initial-state mapping above are preserved from
  code and the earlier source-reviewed audits. Searches covered KB metadata,
  the complete local topic synthesis, relevant presentation record, and equations
  source. The linked paper artifacts are outside the current approved source
  access; no network/source-library access was requested merely to migrate
  software. Consequence: no re-derivation, reinterpretation, new material claim,
  or parameter change. If such a change becomes necessary, obtain the exact
  qualifying source and renewed plan approval first. This does not block tests
  of unchanged implementation behavior.


## Final preservation and documentation checks

All 75 accepted artifacts (5,463,738 bytes) and the immutable proposal digest
were verified again after tests. The accepted snapshots were not regenerated.
`.gitattributes` extends the existing source-byte preservation rules to all
accepted artifacts and the historical proposal, so Git transfers cannot normalize
their line endings.
The nine distributed files still unchanged since import pass this command:

```bash
rg '  (.*\.m|PBSScript)$' SOURCE_SHA256SUMS | rg -v '  (main|field_eta|rk4_4llg)\.m$' | sha256sum -c -
git -c core.whitespace=cr-at-eol diff --check
```

`SOURCE_SHA256SUMS`, constants, switch defaults, RHS, both pulse helpers, and
the C diagnostic also match HEAD byte-for-byte. The three changed original
MATLAB files retain CRLF. Plain `git diff --check` flags those preserved CRLF
lines; the repository-aware `cr-at-eol` check passes. The numerical diff contains no formula changes.
The initial README checkout-location note and both pre-existing CHANGELOG
relocation entries remain intact. Generated candidates/tests are ignored, and
accepted data remain versionable. No files in the parent adoption-matrix
repository or publication archive were edited.

Documentation updates cover the API/customization example, result schema and
compatibility limits, benchmark ownership/commands, figure-setting calls and
loading, protected historical verification commands, durable agent checks and
one grouped changelog entry. Completed planning details now live in this report;
`plan.md` retains the outcome and the R1 source-evidence limitation only.
