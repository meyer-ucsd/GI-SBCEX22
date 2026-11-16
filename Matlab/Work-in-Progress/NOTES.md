# Work-in-Progress Notes

## 2026-10-14: Most promising dataset for the geoacoustic inversion

**JD 147, 20:30 UTC file (`RAVA01.22147203000.sio`), source tow Track 8, VLA1.**

Evidence (`MFP/MFP.m`: XBT #11 sound speed profile, seabed of `MFP.m`, 5 s windows):

- Bartlett value at the GPS source position 0.43 (mean of 12 windows), the highest of all six files. The cap (largest eigenvalue of the cross-spectral matrix) is 0.66, so about 65% of the attainable correlation is matched.
- MFP peak at the GPS source position in 12 of 12 windows (range about 0.98 km, depth about 125 m).
- Short range, so the path is less affected by sound speed changes along the track.
- The source range is known from the ship's GPS (layback 180 m), so it can serve as a tight prior.

Caveats:

- The 21:00 file (receding source, about 1.05 km) matches almost as well (0.39, 12 of 12). Unlike 20:30, it was held out of the sound speed selection (`tuneSoundSpeedMFP.m`), so it is the cleaner check. A joint inversion of 20:30 and 21:00 is preferable to 20:30 alone.
- At about 1 km the seabed attenuation is poorly constrained (the synthetic sensitivity study already showed rhoBot, rhoH, and attH unresolved). The 21:10-21:30 files (1.7-3 km) add range diversity but match worse.
- The sound speed profile is a single XBT cast, taken 1 h later and 3.4 km east. Errors in it will map into the seabed parameters.
- The MFP peaks fall about 5% short of the GPS range. With a tight range prior, the inversion has to explain this through water depth or the seabed.

Status: the GI is set up for the 21:00 file, not 20:30 (see the 2026-11-11 entry).

## 2026-10-31: Hydrophone depths when the water depth is inferred

See `GI/WaterDepthOptions.md`.

## 2026-11-11: GI set up for the MFP at 21:00

`GI/mainData14L1H.m` now uses the setup of `MFP/MFP.m` at 21:00 UTC:

- File `RAVA01.22147210000.sio`, first averaging window (15 snapshots, 5.2 s). The cross-spectral matrices are identical to those of `MFP.m`.
- Sound speed profile: XBT #11 with the salinity of CTD #16.
- Source range prior: centred on the GPS range of the window (1030 m, layback 180 m), standard deviation 100 m.
- Likelihood: the noise variance of each tone is unknown and integrated out, log L = -16 * sum over tones of log(1 - Bartlett value). The earlier fixed SNR factor of 10 was about 5 times too sharp for Bartlett values of 0.4-0.5.

- Known parameters: the densities and attenuations of the layer and the half-space (state entries 7-10, 13, 14) have limited sensitivity at this range (mean Bartlett value 0.96 or higher over their prior ranges) and are kept at the MFP environment values (`scenario.isKnown`). Eight parameters remain unknown. `GI/main14L1H.m` uses the same setting.

Check at this window with the MFP seabed:

- At the MFP peak (1030 m range, 125 m depth) the GI forward model gives the same Bartlett value as `MFP.m` (0.405; the cap is 0.705).
- A scan over range, source depth, and water depth has its best fit at 1026 m, 125 m, and 200 m (Bartlett value 0.424). Tilt 0 fits best. All are inside the priors.

`GI/main14L1H.m` (synthetic data) uses the same sound speed profile and source position (1030 m, 125 m).

A full inversion run (70,000 samples, 10 temperatures) was started on `meyer01.ucsd.edu` on 2026-11-11; see `CHANGES.md`, Section 6, for the setup and where the results are written.

Not done: the joint inversion with the 20:30 file.

## 2026-11-13: First inversion results

The run of 2026-11-11 was stopped by a server reboot; its first 30,000 samples are used. Details and tables are in `CHANGES.md` in the repository root:

- Section 7: estimates, Bartlett values of each tone, and why the layer interface is not resolved (the data resolve the sound speed against depth, about 1555 m/s at the seafloor and about 1586 m/s below 1 m, but no interface).
- Section 8: a second inversion with a continuous sound speed at the interface (`GI/mainData14L1HContinuous.m`), started on 2026-11-13.
- Section 9: the 15 averaged snapshots count as one in the likelihood; the data support an effective count of 2. Not applied.
- Section 10: how the noise variance of each tone could be sampled. Not implemented.

The open points are listed at the top of `CHANGES.md`.
