# Settings for Fig. 2 and Fig. 4(a)

Recorded on 2026-10-29 for Zhengde Xu, Xue Zhang, Yixiao Qiao, Gengchiau Liang,
Shuyuan Shi, and Zhifeng Zhu, “Deterministic spin-orbit torque switching including
the interplay between spin polarization and kagome plane in Mn3Sn,”
Physical Review B **109**, 134433 (2024),
[DOI: 10.1103/PhysRevB.109.134433](https://doi.org/10.1103/PhysRevB.109.134433).
The published settings come from Sec. II and Figs. 2 and 4; the MATLAB seed
mapping and original measured results come from the
[archived-integrator audit](docs/fig2-4-original-audit.md).
The later [RK4 correction verification](docs/rk4-verification.md) supersedes
the numerical verification scope below; the panel parameter settings remain valid.

The existing three-sublattice LLGS model supports the switching curves in
Fig. 2 and Fig. 4(a). Fig. 4(b) uses a separate ferromagnetic model that is
not implemented in this repository.

## Run in a separate source copy

Copy the distributed `.m` files into a new directory for each case and edit
the existing assignments in that copy's `main.m`. Keep each assignment before
the expressions that use it, particularly pulse generation and initial-spin
construction. Setting variables before calling `main` does not override its
parameters because the script starts with `clear`.

Run `main` from the copied source directory. It overwrites `final.mat` and
appends to `result.txt`; preserve previous results. See [README.md](README.md)
for execution details. The archived source in the repository was not changed
for this settings record.

## Common settings

Retain the following existing values in every Fig. 2 and Fig. 4(a) case:

| Quantity | MATLAB assignment or value |
|---|---|
| Total time | `runtime=5000e-12;` |
| Timestep | `tstep=5e-15;` |
| Sampling interval | `savestep=50;` (0.25 ps) |
| Drive start | `starttime=1000e-12;` |
| Drive duration | `pulsewidth=3000e-12;` |
| Pulse edges | `risetime=0; downtime=0;` |
| Field timing | `Hstarttime=starttime; Hendtime=runtime; Hpulsewidth=pulsewidth;` |
| Gilbert damping | `alp=0.003;` |
| Spin Hall angle | `thetaSH=0.06;` |
| Mn3Sn thickness | `tFL=30e-9;` |
| Magnetization | `Ms_Fe=441.85; Ms_Gd=441.85;` (emu/cm3) |
| Exchange | `Hex_1=0; Hex_2=100.812;` (tesla) |
| Anisotropy | `hk_constant=0.196*1e-3*ele; hk6=2*hk_constant/(3*mub);` |
| DMI | `DMI_constant=0.833*1e-3*ele; DMI=DMI_constant/(3*mub);` |
| Spin polarization | `polSOTD_Fe=[1,0,0]; polSOTD_Gd=[0,0,0];` |
| First-triplet azimuth | `inita_phi=90/180*pi;` |
| STT and field-like SOT amplitudes | `jc_STT=0; jc_SOT2=0;` |

Keep the other archived values unchanged, including zero demagnetization.
In `conf_file.m`, retain `SOT_DLT=1`, `STT_DLT=0`, `STT_FLT=0`,
`thermalnois=0`, `dipolee=0`, and `dimensionlessLLG=0`. Although the archived
`SOT_FLT` flag is 1, its actual torque is zero because `jc_SOT2=0`.

Both current and field are off during 0-1 ns, on during 1-4 ns, and off again
during 4-5 ns. Keep `polSOTD_Fe=[1,0,0]` when reversing the signed current;
changing both signs would undo the intended torque reversal.

## Settings for each panel

`Hext` is in tesla: 100 Oe corresponds to 0.01 T. The archived default
`Hext=[0,0.0250,0]` is 250 Oe and must be changed for these panels.

| Panel | `jc_SOT` (A/m2) | `Hext` (T) | `inita_theta` | Relaxed initial octupole angle | Final angle after drive removal |
|---|---|---|---|---|---|
| Fig. 2(a) | `+50e9` | `[0,+0.01,0]` | `270/180*pi` | +150 degrees | +30 degrees |
| Fig. 2(b) | `+50e9` | `[0,-0.01,0]` | `270/180*pi` | +150 degrees | -150 degrees |
| Fig. 2(c) | `-50e9` | `[0,-0.01,0]` | `270/180*pi` | +150 degrees | -30 degrees |
| Fig. 2(d) | `+50e9` | `[0,+0.01,0]` | Six seeds below | Six states below | +30 degrees for all six |
| Fig. 4(a) | `+50e9` | `[0,+0.01,0]` | `210/180*pi` | -150 degrees | +30 degrees |

`inita_theta` is the first Mn spin's polar angle, not the octupole angle. Keep
the original `ma_init1`, `ma_init2`, and `ma_init3` construction with its
120-degree offsets. For Fig. 2(d), run these six cases separately:

| Relaxed octupole angle | `inita_theta` |
|---|---|
| +150 degrees | `270/180*pi` |
| +90 degrees | `330/180*pi` |
| +30 degrees | `30/180*pi` |
| -30 degrees | `90/180*pi` |
| -90 degrees | `150/180*pi` |
| -150 degrees | `210/180*pi` |

These mappings were checked after relaxation at 0.9 ns. For these six seeds
and this sublattice ordering, the relaxed octupole angle is
$\varphi=60^\circ-\theta_1$ modulo $360^\circ$.

## Plot the signed angle and mean-spin components

Use columns 1-3 only. The paper defines the plotted octupole as the average of
the three unit spins. Preserve its small magnitude for Fig. 4(a); do not
normalize the average to unit length.

After a run, execute this in its output directory:

```matlab
load('final.mat','mmx','mmy','mmz','savestep','tstep');
moct = [mean(mmx(:,1:3),2), ...
        mean(mmy(:,1:3),2), ...
        mean(mmz(:,1:3),2)];
phi_deg = atan2d(moct(:,2),moct(:,3));
phi_deg(vecnorm(moct,2,2)<1e-10) = NaN;

% Physical times of the saved states, reconstructed from the step indices.
t_ns = (0:size(mmx,1)-1)' * savestep * tstep * 1e9;

figure;
plot(t_ns,phi_deg);
xlabel('Time (ns)'); ylabel('Signed octupole angle (deg)');

figure;
plot(t_ns,moct);
xlabel('Time (ns)'); ylabel('Mean spin components');
legend('m_{oct,x}','m_{oct,y}','m_{oct,z}');
```

The exact ideal 120-degree seed has zero net moment, so its angle at time zero
is undefined. The small-moment mask above is for plotting only. Avoid
`theta_mtot.m` for Fig. 2: it replaces the signed transverse component with a
nonnegative magnitude and cannot display the required negative angles.
Reconstructing time from step indices also avoids the archived `linspace`
time-label discrepancy.

## Fig. 4(a): initial relaxation and expected components

The default ideal 120-degree seed produces startup ringing before the drive.
To obtain the flat initial segment drawn in the paper, initialize a fresh run
with the six spin vectors at 0.9 ns from a preceding Fig. 4(a) run, using the
same model and parameters. Assign those vectors to `ma_init1` through
`mb_init3` after the normal initialization block and before integration.
Retain the 1-4 ns pulse schedule in the fresh run.

In the diagnostic check, this equilibrated initialization changed the driven
spin components by at most $5.97\times10^{-10}$ relative to the original-seed
run. It removes startup ringing without changing the switching result. This
is a verified way to match the flat segment; the paper's exact initialization
procedure was not independently established.

Measured Fig. 4(a) values were approximately:

- Before the drive: $\mathbf m_{\rm oct}=(0,-0.00173050,-0.00299732)$.
- Zero crossing of $m_{{\rm oct},z}$: 1.39925 ns.
- After final relaxation: $\mathbf m_{\rm oct}=(0,+0.00173050,+0.00299732)$.

## Original verification scope and saved evidence (before RK4 correction)

Eight full 5 ns cases were run with a faster C diagnostic preserving the
archived fields, torques, integration stages, normalization, and pulse
indexing. An additional full run checked equilibrated initialization.
Original MATLAB was used for one 20 ps pilot and four 20 ps driven-state
replays. The largest MATLAB/diagnostic spin-component difference was
$4.79\times10^{-12}$. Final angles and curve shapes agreed with the paper;
no digitized reference curves were available for a pointwise error test.

The original audit preserved the archived half-step fourth stage; it did not
establish timestep convergence. The working integrator now uses the corrected
full-step fourth stage; see the later verification linked above.
Fig. 4(b), with its ferromagnet, current
$7\times10^{11}$ A/m$^2$, and field 400 Oe, cannot be obtained by changing
only the drive settings in this Mn3Sn model.

The original audit is in [docs/fig2-4-original-audit.md](docs/fig2-4-original-audit.md).
Local plots and raw evidence are in
`.sisyphus/fig2-4-check-20261029/`, which is ignored by Git and may be absent
from a fresh checkout:

- [Fig. 2 curves](.sisyphus/fig2-4-check-20261029/fig2-diagnostic.png).
- [Fig. 4(a), original seed](.sisyphus/fig2-4-check-20261029/fig4a-diagnostic.png).
- [Fig. 4(a), equilibrated seed](.sisyphus/fig2-4-check-20261029/fig4a-equilibrated-diagnostic.png).
- `results.csv`, `matlab-crosschecks.json`, and `provenance.json` record
  measured results, MATLAB comparisons, and source hashes.
