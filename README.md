# Mn3Sn_3atoms

MATLAB macrospin code copied without source changes from the archived `code/fig5`
folder associated with [Physical Review B 109, 134433 (2024)](https://doi.org/10.1103/PhysRevB.109.134433).
The local source archive is `projects/published/2024.04-SOT Mn3Sn-zhengde-PRB/code/fig5`.

The default configuration evolves three noncollinear fixed-length macrospins.
Six vectors are stored; `Hex_1=0` decouples the other triplet. This is a spatially
uniform model. `main.m` runs one parameter case rather than the complete Fig. 5 sweep.

## Run

Use MATLAB from this repository's root:

```bash
matlab -batch "run('main.m')"
```

The CPU path has previously been exercised with MATLAB R2024b. The default
configuration does not require a GPU; the archived `PBSScript` requests a GPU
queue and needs adaptation to a particular cluster. Thermal noise is disabled;
enabling it uses `normrnd` (Statistics and Machine Learning Toolbox).

Defaults in `main.m` include a 250 Oe field, current density $5\times10^{10}$ A/m$^2$,
damping 0.003, a 5 fs timestep, 1 ns initial relaxation, drive from 1 to 4 ns,
and relaxation until 5 ns. Parameters and switches are in `main.m` and `conf_file.m`.

`main.m` overwrites `final.mat` with the workspace. `rk4_4llg.m` appends rows to
`result.txt`; the header/reset block in `main.m` is disabled. Preserve existing
results or run in a separate copy before launching. The archived `final.mat` and
`result.txt` were copied locally but are ignored by Git and are not distributed
through this repository.

## Preservation and limitations

`SOURCE_SHA256SUMS` records all 14 original files, including the two local result
files. All 11 MATLAB files and `PBSScript` retain their original bytes and line
endings. To check a local copy containing the archived results:

```bash
sha256sum -c SOURCE_SHA256SUMS
```

Known issues are preserved: the fourth stage in `rk4_4llg.m` uses a half-step
increment, `theta_mtot.m` discards angular sign, and saved time labels have a
5 fs offset. Prior checks cover selected deterministic trajectories and switching
cases; they do not establish full numerical validation or complete reproduction
of the publication. No new simulation was run for this import.

The source archive contained no license; no license has been added.
