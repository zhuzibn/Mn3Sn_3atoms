# RK4 fourth-stage correction and Figures 2, 4, 5 verification

## Goal and Success Criteria

Implement the user-requested six-line fourth-stage correction, preserving the
LLGS model and all parameters. Compare corrected and archived integration,
then check timestep convergence of the published switching conclusions [1].
This continues the earlier audit; its complete record is preserved in
[docs/fig2-4-original-audit.md](docs/fig2-4-original-audit.md).

## Model Classification and Equation Family

Class 5: spatially uniform, three-sublattice noncollinear antiferromagnet with
fixed-length LLGS, as explicitly defined by [1, Sec. II]. The active triplet is
stored in columns 1-3. Three additional unit vectors are dynamically decoupled
because `Hex_1=0`; retain them in cross-checks. Electronic structure, domains,
and spatial nucleation are outside this model.

## Existing Behavior and Reference Implementations

`main.m`, `conf_file.m`, `constantfile.m`, `field_eta.m`, `LLG_solver.m`,
`rk4_4llg.m`, both pulse functions, and `theta_mtot.m` were inspected.
The previous audit is preserved in docs/fig2-4-original-audit.md. Figure 5 is now included in the new verification.
The default field is 250 Oe and the first-spin seed is 210 degrees.
`theta_mtot.m` folds angular sign; use signed post-processing for Fig. 2.
The archived fourth stage incorrectly uses a half step. The user explicitly requests its correction to a full third-stage increment for all six spins.

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

Use the six first-spin seeds 30, 90, 150, 210, 270, 330 degrees. Their relaxed
octupole angles are respectively 30, -30, -90, -150, 150, 90 degrees.
Use signed atan2 of the mean spin; the ideal zero-moment seed has no defined
initial octupole angle. Retain per-step normalization, pulse indexing,
sampling and the known saved-time offset. Correct only the fourth-stage state
from m + dt*k3/2 to m + dt*k3. Piecewise-constant fields are frozen per step.
No thermal-noise validation or general time-dependent-drive order is claimed.

Run isolated deterministic diagnostics at 5, 2.5 and 1.25 fs with identical
physical sampling intervals (0.25 ps), 5 ns duration, drive from 1 to 4 ns.
Record physical times separately from legacy labels. Keep raw outputs in
.sisyphus/rk4-verification-20261029/ and retain reproducible validation tools.
Preserve archived results and SOURCE_SHA256SUMS.

## Implementation Mapping

| Stage | Implementation | Verification gate |
|---|---|---|
| Correction | Six k3 increments in rk4_4llg.m | Exact six-line diff; CRLF preserved |
| Integrator check | Constant-field precession, undamped and damped, through the actual MATLAB script | Fourth-order error reduction under timestep halving; archived version fails |
| Diagnostic check | Adapt existing deterministic C audit to corrected stage and variable dt | MATLAB pilot and driven replays agree within 1e-10 per spin component |
| Figure runs | Fig. 2: all six seeds and all four sign combinations; Fig. 4(a) components; Fig. 5(a) 175-500 Oe published fields and Fig. 5(b,c) six seeds at 1000 Oe, both current signs | Finite unit spins, endpoints and transition behavior recorded; compare 5/2.5/1.25 fs |
| Report | Quantitative comparison, plots, README/settings/changelog updates | Distinguish verified Mn3Sn claims from unavailable FM comparison |

Proceed to each simulation stage only after the preceding numerical gate.
The existing fields, explicit RHS, integration, and case orchestration remain
separate. No new material model or structure builder is involved.

## Verification and Acceptance Criteria

- Analytical constant-field test: normalized RK4 global error should decrease
  approximately 16-fold per timestep halving (observed order 3.8-4.2).
- MATLAB/C transcription: maximum absolute spin-component discrepancy <1e-10
  over 20 ps pilot and driven replays, including Fig. 5 regimes.
- Sampled spin-norm error <1e-12; every sample finite.
- Fig. 2/Table I: all six initial states reach +30, -150, -30, +150 degrees
  for (+J,+H), (+J,-H), (-J,-H), (-J,+H), within 0.1 degree [1].
- Fig. 4(a): negative-to-positive mean z, approximately 1e-3 components,
  subnanosecond transition after drive onset [1, p. 134433-5]. Full FM
  comparison remains unavailable; compare Mn3Sn polarity with published FM.
- Fig. 5(a): test all published fields 175, 200, 225, 250, 275, 300, 325,
  350, 375, 400, 450, 500 Oe at +5e10 A/m2, seed 210 degrees. Report the
  boundary bracket rather than assume the published approximately 275 Oe.
- Fig. 5(b,c): all six seeds at +1000 Oe and +/-5e10 A/m2 should reach
  near +90 degrees after pulse removal, independent of current sign [1].
  Distinguish the driven plateau from the relaxed endpoint.
- Timestep convergence: identical destinations, switching-time changes below
  1 ps, and mean-spin differences below 1e-5 at common physical sample times.
  If a boundary case fails, refine the boundary and report sensitivity instead
  of hiding the failure or changing the physical model.

### Completed verification (2026-10-29)

The six-line correction is complete. Both analytical MATLAB tests demonstrate
fourth-order convergence; the archived variant fails that gate. The pilot and
eight driven MATLAB/C comparisons pass (maximum spin error 8.89e-12).
All 192 full-length diagnostic trajectories are finite and normalized.
All 48 physical cases pass timestep convergence, with maximum mean-spin
changes 2.14e-9 and 1.34e-10 for successive halvings. Figure 2 destinations,
Figure 4(a) polarity, and Figure 5 final-state selection survive. Figure 4(b)
is excluded from numerical verification at the user’s explicit request. During the 1000 Oe
pulse, opposite current signs give different tilt angles; only their relaxed
final states coincide. See [the full results](docs/rk4-verification.md).

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

- The current user request explicitly authorizes the narrow RK4 correction
  and figure verification. It supersedes the prior audit's preserve-bug scope.
  No substantial physics changes are proposed.
- Class 5 degrees of freedom are already established by the preceding audit:
  six stored unit vectors, one active noncollinear three-sublattice macrospin.
- The user explicitly excluded verification of the ferromagnetic curve.
  Fig. 4(b) ferromagnetic parameters remain REFERENCE MISSING after consulting
  the indexed paper summary, source PDF and repository. No FM model is added.
- Published numerical trace data are unavailable. Plot agreement is qualitative;
  convergence and endpoint comparisons provide independent numerical evidence.
- Equations consulted: spintronic_methods.tex and sections/llg_equation.tex
  (eq:llg-gilbert and eq:ll-with-flt), sections/material_parameters.tex
  (Mn3Sn table). These corroborate unchanged conventions, not new physics.
- Exact figure evidence comes from the indexed source PDF, printed pp. 3-5,
  including direct visual inspection of p. 5, plus its reviewed summary.
