# Fig. 2 and Fig. 4 reproduction check

## Goal and Success Criteria

Check whether the archived Fig. 5 code also represents the Mn3Sn results in
Figs. 2 and 4 of [1]. Preserve all distributed MATLAB source bytes and archived
outputs. Use the faster diagnostic implementation explicitly selected by the
user on 2026-10-29, cross-checked against original MATLAB runs. Distinguish
agreement with published plots from a complete numerical validation.

Success: quantify the six initial-state destinations in Fig. 2(d), the sign
cases in Fig. 2(a-c), and the component dynamics of Fig. 4(a). Identify whether
Fig. 4(b)'s separate ferromagnet is represented. No new ferromagnetic model,
solver correction, production baseline update, or source refactor is in scope.

## Model Classification and Equation Family

Class 5: spatially uniform, three-sublattice noncollinear antiferromagnet with
fixed-length LLGS, as explicitly defined by [1, Sec. II]. The active triplet is
stored in columns 1-3. Three additional unit vectors are dynamically decoupled
because `Hex_1=0`; retain them in cross-checks. Electronic structure, domains,
and spatial nucleation are outside this model.

## Existing Behavior and Reference Implementations

`main.m`, `conf_file.m`, `constantfile.m`, `field_eta.m`, `LLG_solver.m`,
`rk4_4llg.m`, both pulse functions, and `theta_mtot.m` were inspected.
Fig. 5 reproduction is accepted as user-supplied prior evidence, not rerun.
The default field is 250 Oe and the first-spin seed is 210 degrees.
`theta_mtot.m` folds angular sign; use signed post-processing for Fig. 2.
The fourth integrator stage uses a half step. Preserve this behavior in the
diagnostic; do not call it a corrected fourth-order Runge-Kutta method.

The ODE_LLG_integral README and AGENTS.md were read to identify the separate
one-spin model boundary. No parameters are transferred from that repository.
The equations reference's `spintronic_methods.tex`,
`sections/material_parameters.tex`, and `sections/llg_equation.tex` were read:
they confirm the flux-density and explicit-LLGS conventions used below.

## State Variables, Geometry, and Boundaries

Six unit vectors, each with Cartesian components. The active three spins lie
approximately in the yz kagome plane, with spin polarization along +x for
positive current [1, Figs. 1(c), 3(a)]. Geometry enters the torque through
`tFL=30 nm`. Crystal construction, neighbors, boundaries, and a spatial mesh
are not applicable to this macrospin audit.

Define the paper's observable as `moct=mean(m(1:3,:),1)` [1, p. 134433-4],
and its signed angle as `atan2d(moct_y,moct_z)` [1, Fig. 1(b)]. The initial
perfect 120-degree seed has zero net moment, so its angle at exactly time zero
is undefined; compare the relaxed state before the pulse.

## Hamiltonian

For auditing the active fields, the code corresponds to the triangle energy

$$
E=J(m_1\cdot m_2+m_2\cdot m_3+m_3\cdot m_1)
+D\hat x\cdot(m_1\times m_2+m_2\times m_3+m_3\times m_1)
-K\sum_i(n_i\cdot m_i)^2-m_s\sum_i B_{\rm ext}\cdot m_i.
$$

Each displayed triangle pair is counted once. This is the implemented
pair-counting convention; the general pair sums printed in [1, Sec. II] do
not independently resolve multiplicity. The easy-axis angles from +z toward
+y are 30, 270, and 150 degrees in code order. SOT is nonconservative.

## Parameters and Evidence

| Input | Audit value | Source/status |
|---|---|---|
| Mn moment | 3 Bohr magnetons | [1, Sec. II] |
| Exchange | 100.812 T, approximately 17.53 meV / moment | Preserve exact code coefficient; [1, Sec. II] gives energy |
| DMI | 0.833 meV / moment | [1, Sec. II], exact code constants |
| Anisotropy field | 2 x 0.196 meV / moment | [1, Sec. II], code convention |
| Magnetization | 441.85 emu/cm3 = 441850 A/m | Code; [1] uses 6 moments / 0.3778 nm3 |
| Damping, spin Hall angle | 0.003, 0.06 | [1, Sec. II] |
| Thickness | 30 nm | [1, Sec. II] |
| Current magnitude, field magnitude | 5e10 A/m2, 0.01 T | [1, Fig. 2 and Fig. 4(a)] |
| Pulse | 1 ns to 4 ns, total 5 ns | [1, Fig. 2] |
| Integration step | 5 fs | [1, p. 134433-3]; original stage coefficients retained |
| Sampling | every 50 steps | Code; 0.25 ps |
| Gyromagnetic ratio | 1.760859644e11 rad/(s T) | Exact archived constant |
| Charge, Bohr magneton, hbar/e | 1.602e-19 C, 9.274e-24 J/T, 6.58211951440e-16 V s | Exact archived constants |
| Noise, STT, FLT, demagnetization, interlayer exchange | zero | Active configuration; matches deterministic DLT scope of [1] |
| Ferromagnet Fig. 4(b) | J=7e11 A/m2, field=400 Oe | Figure labels; full material/anisotropy parameter set not established |

## Effective Fields and Units Check

Use `B_i=-(1/ms)*dE/dm_i`, in tesla. Exchange is
`-Hex_2*(m_j+m_k)`; anisotropy is `(2K/ms)*(n_i dot m_i)*n_i`.
For cyclic (i,j,k), DMI is `(D/ms)*cross(xhat,m_j-m_k)`.
These reproduce the active expressions in `field_eta.m` and the Hamiltonian
terms in [1, Sec. II]. Apply Oe-to-tesla factor 1e-4 to the drive field.
The torque field is `b=(hbar/e)*thetaSH*J/(2*tFL*Ms_SI)` in tesla; the code's
`hbar` value already represents hbar/e numerically in SI, so do not divide
by the charge again.

## Dynamical Equation and Nonconservative Torques

Preserve the explicit code RHS for each spin:

$$
\dot m=\frac{\gamma}{1+\alpha^2}
[-m\times B-\alpha m\times(m\times B)
-b m\times(m\times p)+\alpha b m\times p].
$$

This is the solved Gilbert form of [1, Sec. II], consistent with reference
`eq:ll-with-flt`. The spectator triplet has zero polarization; retain its
exchange and applied field. No stochastic convention or RNG is applicable.

## Initial Conditions, Solver, and Outputs

Use the original spherical-coordinate seed construction and normalization
after every step. Verify the relaxed octupole mapping, predicted from the
implemented anisotropy to be `phi=60-inita_theta` modulo 360 degrees for these
six seed states. Thus Fig. 2(a-c) needs first-spin seed 270 degrees, while
Fig. 4(a)'s initial -150-degree state uses the existing 210-degree seed.

The diagnostic preserves the four stage locations (0, 1/2, 1/2, 1/2), the
weights (1,2,2,1)/6, frozen drive per step, and the original step count.
Save both physical integration times and MATLAB-style linspace labels.
Store diagnostic code, copied MATLAB inputs, raw CSVs, logs, and figures in
`.sisyphus/fig2-4-check-20261029/`, separate from archived results.

## Implementation Mapping

| Stage | Implementation | Verification gate |
|---|---|---|
| Source/figure mapping | Inspect paper pages 2-5 and active source | Units, signs, observable, initial states identified |
| Diagnostic kernel | Minimal deterministic C transcription of six-spin fields, RHS, and existing stages | Original MATLAB short-trajectory component error below 1e-10 |
| Figure cases | Eight 5 ns cases: six positive/positive seeds and two additional sign cases | Finite unit spins; endpoints within 0.1 degree of paper states |
| Figure comparison | Signed angles and three unnormalized mean-spin components | Compare curve shapes, scales, polarity, and switching times with published figures |
| Record | Record results and limitations here and export plots | All original distributed checksums pass; no source edits |

Do not claim a later gate passed until its preceding verification passes.
The diagnostic RHS consumes explicit fields and torque amplitudes. Fields,
RHS, integrator, and case orchestration stay separate. This is an audit tool,
not a replacement production solver.

## Verification and Acceptance Criteria

The original 20 ps pilot ran in 9.90 s of MATLAB computation. Export its
sampled vectors and cross-check against C. Also replay short trajectories
from driven states to check switching-region dynamics and current/field signs
against unchanged MATLAB kernels. Use maximum absolute spin-component error
below 1e-10 as a strict transcription check, not as a discretization-error
bound. Require sampled norm errors below 1e-12.

For Fig. 2(a-c), expected final angles are +30, -150, and -30 degrees.
All six Fig. 2(d) seeds should end at +30 degrees [1, Fig. 2 and Table I].
Fig. 4(a) should show negative-to-positive z polarity with component scale
around 1e-3 [1, Fig. 4]. Figure reading is approximate: no numerical reference
dataset has been supplied, so do not report curve-wise quantitative identity.

### Completed results (2026-10-29)

The diagnostic reproduced all eight tested switching destinations and the
published transient shapes on visual comparison. The raw CSVs are the full
5 ns **C diagnostic** trajectories; original MATLAB was run for the 20 ps
pilot and four 20 ps driven-state replays, not for all full-length cases.

| Case | Relaxed initial octupole | J (A/m2) | H (Oe) | Final angle (degrees) |
|---|---:|---:|---:|---:|
| Fig. 2(a) | +150 | +5e10 | +100 | +29.99999959 |
| Fig. 2(b) | +150 | +5e10 | -100 | -150.00000041 |
| Fig. 2(c) | +150 | -5e10 | -100 | -29.99999959 |
| Fig. 2(d), other seeds | +90, +30, -30, -90, -150 | +5e10 | +100 | all +29.99999959 |

All samples were finite, and the maximum sampled unit-vector norm error was
2.22e-16. Before pulse removal, the positive-current, positive-field cases
approached approximately +18.95 degrees; after removal they relaxed to +30.
The initial-state mapping was verified from the relaxed trajectories:

| Desired octupole angle | `inita_theta` in degrees |
|---|---:|
| +150 | 270 |
| +90 | 330 |
| +30 | 30 |
| -30 | 90 |
| -90 | 150 |
| -150 | 210 |

The pilot's maximum absolute spin-component difference between original
MATLAB and the diagnostic was 6.57e-14. Four driven replays started at the
diagnostic state at 1.5 ns and lasted 20 ps. Their maximum differences were
4.79e-12 (Fig. 2(a)), 1.33e-12 (Fig. 2(b)), 1.33e-12 (Fig. 2(c)), and
4.79e-12 (Fig. 4(a)). The C replays exactly matched the corresponding saved
segments of the full C trajectories. All were below the 1e-10 gate.

For Fig. 4(a), the default 210-degree first-spin seed produces the required
-150-degree relaxed octupole. With field changed to +100 Oe, its mean z
component crosses zero at approximately 1.39925 ns. Before the drive,
`moct=(approximately 0,-0.00173050,-0.00299732)`; after final relaxation,
`moct=(approximately 0,+0.00173050,+0.00299732)`. The driven y-component peak
is approximately 0.00349170 and the driven z plateau approximately 0.00327417.
These signs, scales, and transient shapes agree visually with [1, Fig. 4(a)].

The ideal 120-degree seed has a startup transient absent from the flat initial
trace drawn in the paper. An additional 5 ns diagnostic initialized with the
same model's relaxed state at 0.9 ns removes that transient. Its maximum
spin-component difference from the original-seed trajectory after the 1 ns
drive onset was 5.97e-10. Both initialization variants are retained and labeled.
The equilibrated-seed plot establishes that no field or torque change is
needed to obtain the flat initial segment; the paper's exact initialization
procedure is not independently established.

Fig. 4(b) remains **outside this repository's implemented model**. It uses a
perpendicular ferromagnet, J=7e11 A/m2 and H=400 Oe [1, Fig. 4(b)]. The generic
LLGS vector equation can be reused, but `field_eta.m` currently hardcodes
three different Mn anisotropy axes and antiferromagnetic exchange/DMI; merely
changing J and H does not turn it into that ferromagnetic simulation.

Artifacts in `.sisyphus/fig2-4-check-20261029/`:

- `fig2-diagnostic.png`: all four Fig. 2 panels.
- `fig4a-diagnostic.png`: Fig. 4(a) components including original-seed startup.
- `fig4a-equilibrated-diagnostic.png`: equilibrated-seed Fig. 4(a) comparison.
- `results.csv`, `results.json`, `features.json`: measured endpoints and features.
- `matlab-crosschecks.json`, `validation.log`, `pilot/matlab.csv`, and
  `replay_*/matlab.csv`: original-MATLAB comparison evidence.
- `diagnostic.c`, `provenance.json`, case CSVs, seeds, copied `.m` files, and
  MATLAB plotting/validation scripts: local reproducibility inputs.

The diagnostic was compiled with
`gcc -O3 -std=c11 -Wall -Wextra -ffp-contract=off diagnostic.c -lm -o diagnostic`.
For example, from that output directory, Fig. 2(a) was run with
`./diagnostic fig2a.csv 270 0.01 5e10 5 1 3`.
The original-source checksum check and `git diff --check` passed. No original
MATLAB source or archived result was changed. Existing README.md and AGENTS.md
edits were preserved. This audit adds this plan/results record; no README or
changelog behavior update is needed because production behavior is unchanged.

## References

[1] Zhengde Xu, Xue Zhang, Yixiao Qiao, Gengchiau Liang, Shuyuan Shi*,
Zhifeng Zhu†, Deterministic spin-orbit torque switching including the interplay
between spin polarization and kagome plane in Mn3Sn, Physical Review B
**109**, 134433 (2024). DOI: https://doi.org/10.1103/PhysRevB.109.134433.
Evidence: reviewed local summary and directly inspected source PDF, especially
printed pages 134433-2 to 134433-5. Paper KB ID:
`AFM/2024-Deterministic spin-orbit torque switching including the interplay between spin-PRB-zhengde Xu`.
Presentation KB `notes/ee237/week15a-afm/slides.md`, slides 25-27, was checked
for context; the publication supplies the quantitative evidence.

## Assumptions, Missing References, Risks, and Approval Questions

- User approved the faster diagnostic plus original-MATLAB cross-checks in
  this conversation. This record makes that selected audit scope concrete.
- Existing README.md and AGENTS.md edits are unrelated and preserved.
- Preserve the archived half-step fourth stage. No timestep-convergence or
  complete scientific-validation claim is authorized by a matching plot.
- Fig. 4(b) is a different model. Its complete ferromagnetic parameter set is
  REFERENCE MISSING in the inspected main paper and this repository; do not
  invent it or substitute another paper's parameter set.
- Report full-length diagnostic runs separately from original MATLAB runs.
- No outstanding design approval is required within the user's selected audit
  scope. A new production model or solver correction would be a separate task.
