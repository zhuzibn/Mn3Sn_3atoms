# CQ-03 retained storage: completed

Revision 1 was approved by the user on 2026-11-20 and implemented. Rolling
six-spin state and retained output replace full state/unused diagnostic histories.
All 11 accepted cases, five sampling controls, exact text/clocks, analytical
convergence and nine MATLAB/C comparisons pass. Measured state/diagnostic storage
is 2.88 MB instead of 312 MB; this is not total process memory.

See [the completion report](docs/retained-storage-verification.md) for commands,
artifacts, measurements and the preserved approved specification. Equations,
defaults, accepted artifacts and import checksums remain unchanged.

## Separate backlog

The [existing scientific specification and R1 evidence gap](docs/code-quality-verification.md)
remain authoritative. Exact material/axis/initial-state attribution, unsupported
physics, broader publication sweeps and new observables require separate scope;
none was implemented by this storage task.
