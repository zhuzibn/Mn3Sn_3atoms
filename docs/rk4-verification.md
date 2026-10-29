# RK4 correction and verification of Figures 2, 4, and 5

The production correction changes only the six fourth-stage states in
`rk4_4llg.m` from `m + k3*dt/2` to `m + k3*dt`. The second and third stages
remain half steps; weights and final normalization are unchanged. The model
is the existing spatially uniform, fixed-length, three-sublattice noncollinear
LLGS model (Class 5), with three additional decoupled stored spins.

The source evidence is Zhengde Xu, Xue Zhang, Yixiao Qiao, Gengchiau Liang,
Shuyuan Shi, and Zhifeng Zhu, “Deterministic spin-orbit torque switching
including the interplay between spin polarization and kagome plane in Mn3Sn,”
Physical Review B **109**, 134433 (2024),
[DOI: 10.1103/PhysRevB.109.134433](https://doi.org/10.1103/PhysRevB.109.134433).
The reviewed paper-KB record and indexed PDF were consulted, specifically
Sec. II, Fig. 2, Table I, and printed page 134433-5 (Figs. 4 and 5).
The exact KB ID and unchanged Hamiltonian/field conventions are in
[plan.md](../plan.md). The equations reference files consulted were
`spintronic_methods.tex`, `sections/llg_equation.tex` (`eq:llg-gilbert`,
`eq:ll-with-flt`), and `sections/material_parameters.tex`; they corroborate
the existing flux-density units and torque signs. No physical parameters,
field terms, torque terms, or stochastic conventions were changed.

## Measured results

**Figures 2, 4(a), and 5 retain their tested qualitative conclusions after
correction. Figure 4(b) is excluded at the user’s request.** The correction
does change transient trajectories; agreement of final states is not a claim
that the defective and corrected integrators are interchangeable.

### Figure 2: deterministic destinations survive

All six initial states were tested for each of the four sign combinations,
at all three corrected timesteps. Every final angle agrees with Table I to
within 0.000001 degree:

| Current / field signs | Corrected final octupole angle | Number of initial states |
|---|---:|---:|
| +J, +100 Oe | +30 degrees | 6 |
| +J, -100 Oe | -150 degrees | 6 |
| -J, -100 Oe | -30 degrees | 6 |
| -J, +100 Oe | +150 degrees | 6 |

Thus both sign selection and independence from the six initial states
survive. The signed angle wraps at +/-180 degrees; vertical wrap segments
in the plots are coordinate discontinuities, not instantaneous spin jumps.

### Figure 4(a): Mn3Sn polarity survives

At +5e10 A/m2 and +100 Oe, starting from the relaxed -150-degree state:

| Observable | Corrected result (5 fs) |
|---|---:|
| Mean z before drive | -0.002997322420 |
| Mean z after relaxation | +0.002997322433 |
| Mean y after relaxation | +0.001730504885 |
| Mean z just before drive removal | +0.003274171095 |
| Maximum driven mean y | +0.003491698424 |
| Maximum absolute driven mean x | 0.000160705676 |
| Mean-z zero crossing | 1.399001533609 ns |

The zero crossing occurs approximately 0.399 ns after the drive starts.
Its time is 1.399001533609 ns at both 2.5 and 1.25 fs to the displayed
precision. The archived integrator gives 1.399001384685 ns. The small
out-of-plane component and the overall component traces remain consistent
with Fig. 4(a), including its relatively weak precession during reversal.

The positive final z polarity remains opposite to the **published**
ferromagnetic trace in Fig. 4(b). This is not an independent rerun of the
ferromagnet or a quantitative validation of its precession amplitude.

The largest corrected-versus-archived mean-spin difference for this case is
0.000618546 at 0.030 ns, during initial relaxation. After 1 ns it is at most
0.00000583579. Across all cases, the largest such difference is 0.000714236
(the -90-degree initial state, also at 0.030 ns). Therefore the fix matters
for transient accuracy even though these switching conclusions survive.
The two localized comparisons are recorded in `transient-comparison.json`.

### Figure 5: high-field final-state selection survives

At +5e10 A/m2 with the original 210-degree first-spin seed:

| Tested field values (Oe) | Final octupole state, all corrected timesteps |
|---|---|
| 175, 200, 225, 250, 275 | +30 degrees |
| 300, 325, 350, 375, 400, 450, 500 | +90 degrees |

The archived integrator gives the same classification. With this pulse
protocol, the sampled transition is bracketed by **275 < Hcrit <= 300 Oe**,
consistent with the paper's description of a transition above approximately
275 Oe. This sweep does not locate a more precise critical field.

At +1000 Oe, all six initial states relax to +90 degrees for **both**
+5e10 and -5e10 A/m2, at each of the three corrected timesteps. Thus current
reversal no longer selects different final states in this high-field regime.

The driven state is not exactly current-independent: just before pulse
removal, the angles are approximately **83.8311 degrees** for positive
current and **96.1689 degrees** for negative current. Both subsequently
relax to 90 degrees. At 300 Oe the driven angle is about 74.7462 degrees,
again followed by relaxation to 90 degrees. The conclusion that survives
is the loss of current-selectable **final-state** control, not literal
absence of SOT's influence during the pulse.

## Numerical checks and interpretation

The analytical check executes the actual MATLAB integration script on six
independent spins in a constant +z field. For an initial +x spin and
dimensionless time $u=\gamma Bt/(1+\alpha^2)$, the exact solution is

$$
\mathbf m(u)=\left(\operatorname{sech}(\alpha u)\cos u,
\operatorname{sech}(\alpha u)\sin u,\tanh(\alpha u)\right).
$$

This is derived directly from the existing explicit LLGS equation with all
torques and internal fields set to zero. Tests integrate to $u=1$ using
10, 20, 40, and 80 steps, at damping 0 and 0.1. The latter is a test fixture,
not a changed Mn3Sn parameter. The test reconstructs the archived half-step
stage in an isolated copy and requires it to fail the fourth-order gate.
The normalization can improve observed order in special limits; the
undamped result is not a general order claim for the defective scheme.

All numerical gates passed using MATLAB R2024b and GCC 11.4.0:

| Check | Measured result |
|---|---:|
| Corrected undamped precession order | 3.9961, 3.9990, 3.9998 |
| Corrected damped precession order | 3.9978, 3.9998, 4.0002 |
| Archived undamped precession order | 1.9975, 1.9994, 1.9998 |
| Archived damped precession order | 1.1222, 1.0665, 1.0347 |
| MATLAB/C pilot max spin-component error | 5.55e-14 |
| MATLAB/C max error over pilot + eight driven replays | 8.89e-12 |
| Maximum sampled spin-norm error over 192 trajectories | 2.22e-16 |
| Maximum mean-spin difference, corrected 5 vs 2.5 fs | 2.14e-9 |
| Maximum mean-spin difference, corrected 2.5 vs 1.25 fs | 1.34e-10 |

The approximately sixteenfold reduction of the latter errors is additional
fourth-order evidence for this deterministic setup. All tested destinations
were unchanged under timestep halving. Exact results are in
`matlab-checks.json`, `summary.csv`, and `analysis.json`.

The full-length simulations use a deterministic C transcription, not full
5 ns MATLAB runs. The short MATLAB replays test all six stored spins and
all four current/field sign combinations. Additional replays cover 275 and
300 Oe and both current signs at 1000 Oe. High-field replays start at
1.02 ns to sample the initial transient; other driven replays start at
1.5 ns. Every replay lasts 20 ps. Restarted C replays must reproduce the
corresponding full-trajectory segments within 1e-14 before MATLAB comparison.

For each of the 48 physical cases, runs compare the archived integrator at
5 fs and corrected RK4 at 5, 2.5, and 1.25 fs: 192 full 5 ns trajectories.
Physical samples are aligned at 0.25 ps intervals. Every sample must be
finite, spin-norm errors must be below 1e-12, and the maximum corrected
mean-spin difference under timestep halving must be below 1e-5. Expected
destinations must agree within 0.1 degree. The Fig. 4(a) zero-crossing times
must differ by less than 1 ps under timestep halving.

These tolerances are numerical acceptance criteria, not experimental error
bars. There are no digitized published curves for a quantitative pointwise
comparison. The ideal 120-degree seed has startup ringing absent from the
paper's relaxed initial trace; the comparison includes this transient and
does not silently substitute a new initialization.

## Reproduce

Requirements: existing GCC, Python 3 standard library (no third-party Python
packages), and MATLAB. No installation or new environment is needed. Run the
following from the repository root in Bash/WSL:

```bash
python3 verification/run_checks.py prepare
```

Then, with MATLAB's current directory set to the repository root:

```matlab
repo = pwd;
addpath(fullfile(repo,'verification'));
out = fullfile(repo,'.sisyphus','rk4-verification-20261029');
check_matlab(out);
```

After the analytical and pilot gates pass, run in Bash/WSL:

```bash
python3 verification/run_checks.py sweep
python3 verification/run_checks.py replays
```

Finish in MATLAB:

```matlab
check_matlab(out);
analyze_figures(out);
```

The runner launches up to eight independent diagnostic processes, each
writing a separate file. Compilation uses
`gcc -O3 -std=c11 -Wall -Wextra -ffp-contract=off`; the archived variant
adds `-DLEGACY_STAGE`. The diagnostic supports only this audit's deterministic
parameter configuration and is not a replacement production solver.

These commands write or replace verification artifacts only under
`.sisyphus/rk4-verification-20261029/`. They do not execute `main.m` in the
repository root or touch the original publication archive. Raw data require
approximately 1.5 GB. The source hashes, MATLAB checks, `analysis.json`,
`summary.csv`, copied MATLAB inputs, replay seeds and all CSV trajectories
remain there. This ignored directory may be absent from a fresh checkout.

Repository copies of the verified plots (also embedded in the README):

The plots show only the corrected trajectories; legends identify physical
components, initial states, or field values. Archived trajectories remain
part of the numerical comparisons above but are not drawn.

- [Figure 2](figures/fig2-corrected.png)
- [Figure 4(a)](figures/fig4a-corrected.png)
- [Figure 5](figures/fig5-corrected.png)

The plotting script writes new exports into the local output directory above.
After reviewing regenerated plots, copy these three PNGs to `docs/figures/`
to refresh the README images.

## Scope and preservation

The user explicitly excluded verification of Figure 4(b)'s ferromagnetic
curve. Its parameter set is not established in this repository or the
inspected main paper; comparison with that panel uses only the published
ferromagnetic polarity and trace. The original publication code folder was
not inspected, and no FM model was introduced. Domains, temperature/noise, other torque flags, and the complete
Fig. 3 phase diagram are not validated by these checks.

Legacy saved-time labels, step count, pulse indexing, and unsigned
`theta_mtot.m` plotting remain unchanged. The audit uses physical times and
`atan2d(mean_y,mean_z)`; the exactly compensated initial seed has an undefined
octupole angle. Plots omit the first 0.05 ns of the angle traces, and reported
endpoints are the common last sampled time, 4.99975 ns. The diagnostic's
stdout additionally reports its final integrated state.

The original [audit](fig2-4-original-audit.md) is preserved as historical
evidence. All eleven unchanged distributed files still match
`SOURCE_SHA256SUMS`; the corrected integrator intentionally differs by six
lines and preserves CRLF. The local archived `result.txt` also matches;
the original `final.mat` is absent, so its checksum cannot be checked.
The manifest itself is unchanged. Use
`git -c core.whitespace=cr-at-eol diff --check` when checking the preserved
CRLF source, which plain `git diff --check` otherwise flags as trailing
whitespace on the six edited lines.
