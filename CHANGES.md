# Changes

*Last updated 2026-11-20.*

This file lists all changes made to the repository after commit `51f7b00` (2026-09-03), the inversion runs on `meyer01.ucsd.edu`, their results, and the open points. Someone taking over the project should read "Status and open points" first, then Sections 3 and 6 to 13.

## Status and open points (2026-11-20)

**Terminology (from 2026-11-15, Section 23 on):** "frame" means one averaging window of 15 snapshots (about 5 s). Sections 1 to 22 and the code call it "window" or "averaging window" (for example `scenario.windowIndexesFit`); the code names are unchanged.

**Where things stand**

- The inversion of the 21:00 file (`mainData14L1H.m`, 8 unknowns) has 30,000 samples. The run was meant to have 70,000 but was stopped by a server reboot (Section 6). The results are in Section 7.
- A second inversion with a continuous sound speed at the layer interface (`mainData14L1HContinuous.m`, 7 unknowns, 30,000 samples) was started on the server on 2026-11-13 at 22:37 PST (Section 8). Its first 20,000 samples were looked at first (Section 11); the run ended on 2026-11-14 at 11:01 PST (41,947 s, no errors), and the complete file is on this Mac as `resultsDataContinuous_run20261113T2237_30000samples.mat`; `showResultsData.m` and `checkHeldOutWindows.m` point to it; the estimates are the same as for the first 20,000 samples (Section 11).
- Results are shown with `showResultsData.m` (Section 7.1).
- A joint inversion of six windows of the 21:00 file with held-out windows is set up and tested locally (`mainData14L1HJoint.m`, `checkHeldOutWindows.m`, Section 13). It was started on the server on 2026-11-14 at 11:02 PST (Section 13.4). It ended on 2026-11-15 at 02:16 PST with 30,000 samples and no errors. The complete file is on this Mac as `resultsDataJoint_run20261114T1102_30000samples.mat`; results in Section 13.6. The first 10,000 samples already improve the held-out windows (0.448 against 0.420, Section 13.5; preliminary).
- A range-dependent inversion with an EOF profile of the water (`mainData14L1HRangeDependent.m`, Section 16) was started on the server on 2026-11-15 at 14:33 PST (Section 23). That run stayed in a secondary mode and was stopped; it was started again from the joint MAP at 23:31 PST (Sections 26 and 27); expected end about noon on 2026-11-17. Its control run with the same profile at both ends is not started.
- The baseline for every model change is the fit of the held-out windows. For the single-window inversion: mean Bartlett 0.482 on its own window, 0.421 on the 11 other windows (Section 13.3).
- **Present reference (2026-11-20):** the joint inversion of the two files at 1 km (`mainData14L1HTwoFiles.m`; 9 unknowns, roughness as a loss, water depth fixed at 204.0 m, logger profiles) ended on 2026-11-20 with 20,000 samples (Sections 44, 51, and 53). One environment fits both files with 0.475 on the fitted and 0.463 on the held-out frames (caps 0.69 and 0.68). The complete file is on this Mac as `resultsDataTwoFiles_run20261118T2114_20000samples.mat`; `showResultsData.m` and `checkHeldOutWindows.m` point to it. No inversion is running on the server.
- The propagation model is chosen with `scenario.model` (Section 50). The main scripts use KRAKEN as a MEX function (`Matlab/KrakenMex`); results files from before are evaluated with `kraken.exe`.
- Next: the plan of the next inversion (proposal in Section 54; Florian Meyer decides).

**Open points**

1. Done on 2026-11-15: the complete joint run is downloaded and evaluated (Section 13.6). The thickness leans against its upper prior bound of 5 m; raise the bound in a later run.
2. Effective number of snapshots: the likelihood counts the 15 averaged snapshots as one. The analysis in Section 9 supports a count of 2. This is not applied yet. Both runs use a count of 1, so their posteriors are too wide by roughly 30%.
3. Noise variance of each tone: currently integrated out. Section 10 lists how to obtain or sample it. Not implemented.
4. A halfspace-only inversion as a comparison (is the layer needed at all?). Not set up.
5. The longer-range files (21:10 to 21:30) and the 20:30 file. No inversion set up. Tests on all five files: Sections 36.4 and 37. The fit falls from 0.47 at 1 km to at most 0.32 at 1.7 to 3 km for any range-independent environment, with data of the same quality; a joint inversion over these ranges is not useful with the present forward model (Section 37.3).
8. Sound speed profile of the water with EOF coefficients as unknowns, range dependent: **ended on 2026-11-17 at 20:58 PST with 20,000 samples; file on this Mac; evaluated in Section 42. Samples 1 to 10,000 are valid (Section 32); from sample 11,000 on the chain sits in a region that exists only because of the adiabatic approximation and is not to be used.** Earlier notes: running on the server since 2026-11-15, 23:31 PST (second start, Section 27; status on 2026-11-16 in Section 28; first 10,000 samples evaluated in Section 32; sample 18,182 of 20,000 on 2026-11-17 at 16:55 PST, expected end between 20:30 and 21:00 PST; the tests of Section 37 ran on the same server and slowed it to about 440 samples per hour). The forward model of this run is in question for the difference between the two ends (open point 13). To do when it has ended: download and evaluate it as listed in Section 23; decide on the control run (Section 16.5). Open: the data requested from Bill Hodgkiss on 2026-11-15 (temperature loggers of VLA1; Section 22). Assessment of what to expect: Section 20.
6. The MFP peaks and the inversion put the source about 20 to 26 m short of the GPS range in all 12 windows of the 21:00 file. This is expected (Section 7.5): the length of the tow cable is not well known, and bathymetry that changes along the path shifts the estimated range (mirage effect). The two cannot be separated without the bathymetry along the track; a first look at the bathymetry is in Section 17 (source end about 3.6 m deeper than the array end by the 3-arc-second grid; test on the data incomplete).
7. `ReferenceCode/getCovariancesDifferences.m` still has the ordering problem noted in Section 1.
10. Temperature loggers of VLA1 and ship data (Section 31, 2026-11-16): the loggers show the lower water column at the array about 2 m/s faster than XBT #11, and the echosounder and the loggers put the water depth at VLA1 at about 204 to 205 m, at the upper bound of the prior (195 to 205 m) and 4 to 5 m above the estimate of the joint inversion. With the logger profile in the forward model (no new unknown) the fit rises from 0.448 to 0.464 on the held-out frames (Section 31.5); most of the gap to 0.70 remains. To do: widen the prior of the water depth, and decide how the logger profile enters the inversion.
11. Plan for the next inversion (Section 33, 2026-11-17): proposed, not set up. Florian Meyer decides.
12. Source track (Section 36.3, 2026-11-17): `getSourceTrackMFP.m` interpolates the ship between three XBT launch positions; the ranges are 28 to 58 m too long for the files from 2100Z on. The GPS of the ship is now in `Matlab/Data/ancillaryData/cruise_data_legC/underway/raw`. To do: read the track from there, and treat the layback (assumed 180 m, about 155 m from the data) as uncertain. The markers of the source in the MFP figures are affected.
13. Adiabatic modes (Section 37.4, 2026-11-17): the range-dependent forward model in `getPressuresFromStateSBCEXP22.m` pairs the modes of the two ends by their index. A test with coupled modes shows that this does not hold for a profile that changes along the path, even at 1 km. For the small differences that the range-dependent run (open point 8) visited, the field of the code agrees with coupled modes (0.99), so its samples are computed correctly; larger differences are computed wrongly, penalized in one case (Section 37.4) and rewarded in another: the second half of the run sits in a region that coupled modes do not confirm (Section 42.3). To do before a further range-dependent inversion: coupled modes in the forward model (scratch version in `/var/tmp/<user>/tests2`, `cm_segments.m` and `cm_fields.m`).
19. Next inversion: **proposal in Section 54 (2026-11-20), not decided.** The same two files with a likelihood for the whole cross-spectral matrix that has the scattered sound as an incoherent part (KRAKEN unchanged; decided on 2026-11-19: 2 independent snapshots for each frame), after a check of that likelihood at the present MAP. Also in the proposal: the mode computations that a proposal does not need (Section 49) and the upper bound of the halfspace speed. Open beside it: the 3.3 m between the two source depths (Sections 51.1 and 53.1).
18. Propagation model (Sections 49 and 50, 2026-11-19): `scenario.model` switches between `'kraken_env'` (`kraken.exe` with files, unchanged), `'kraken_mex'` (the same solver as a MEX function in `Matlab/KrakenMex`, no files; fields equal to 0.999999, 3.6 s against 5.0 s per sample of the two-file script), and `'orca'` (files not in the repository). Built and tested for the server and for the MacBook. **Since 2026-11-19 `'kraken_mex'` is the setting of all main scripts (decision of Florian Meyer, Section 50.5)**; results files from before keep being evaluated with `kraken.exe`. Committed on 2026-11-20. Not yet in the clone on the server (it is at `f0957d7` plus copied files): bring it to the committed state before the next run. The mode computations that a proposal does not need (Section 49) are a separate, larger gain.
17. Joint inversion of the two files at 1 km (`mainData14L1HTwoFiles.m`, Section 43): **done. Ran on the server from 2026-11-18, 21:14 PST to 2026-11-20, 09:52 PST (Section 44); 20,000 samples, no errors; the complete file is on this Mac and evaluated in Section 53** (first 10,000 samples: Section 51; scripts for two files: Section 47). Setup: measured surface roughness, unknown seafloor roughness, water depth fixed at 204.0 m, logger profiles, ranges from the ship GPS.
16. Roughness (Section 41, 2026-11-17): the surface roughness is measured (wave radar, 0.38 to 0.41 m rms). As a loss term it raises the joint fit of the two files at 1 km by 22 to 30 in the log-likelihood, held-out frames included, and changes the seabed that comes out (thin slow layer over a halfspace of 1700 to 1744 m/s instead of 1596 m/s). To do: optional roughness in the scenario and the environment file; decide whether the next inversion uses both files at 1 km.
15. Water depth and hydrophone depths (Section 39, 2026-11-17): the tie of the hydrophone depths to the water depth is not a problem (an independent offset of the array stays within 0.3 m and gains 0.001). The fitted water depth (202.8 m, 199.9 m in the joint inversion) trades off with the range; the measured 204.0 m fits equally and puts the source on the GPS range. To do: fix the water depth at 204.0 m in the next inversion.
14. Data of the experiment folder on the data server (Section 38, 2026-11-17): source depth (1 s), wave radar, 25 m bathymetry, ship positions, wind, and documents are now in `Matlab/Data`. Measured: source at 119 to 121 m in all files, water depth at VLA1 204.0 m, seabed 2.6 to 3.7 m per km deeper towards the source from 2100Z on, swell of 1.5 to 1.7 m. To do: use them as priors or fixed values in the next inversion (Section 38.7); ask for the compass and tilt sensors of VLA1 (Starmon SCL0003, SCL0004, SCL0012), which are not in the folder.
9. ORCA as a second propagation model (`scenario.model = 'Orca'`, Section 30): implemented and checked, no inversion run with it yet. The ORCA files are not in the repository (`Matlab/Orca`, in `.gitignore`) and exist for Linux and Intel macOS only; the clone on the server does not have the new code or the ORCA folder yet (copy them only when no inversion is running there).

**Committed on 2026-11-15** (the commit after `f0957d7`; see `git log`): everything described in Sections 7 to 25, i.e. `CHANGES.md`, the edit of `Matlab/Work-in-Progress/NOTES.md`, the new and edited files in `Matlab/Work-in-Progress/GI` and `Matlab/Work-in-Progress/MFP`, the figures `GI/Results/*.png` and `MFP/Results/MFP_*_MAP.png`, and the four result files `GI/results*.mat` (73 MB in total), which `showResultsData.m`, `checkHeldOutWindows.m`, and `MFP.m` read. The repository is public: the account name on the server and the details of other projects are left out of this file. Not in the repository: the measurements (`Matlab/Data`, `.gitignore`), the Linux KRAKEN binary, and the results of the run of Section 23, which is still running.

**Committed on 2026-11-20** (the commit after `cc0741f`; see `git log`): everything described in Sections 26 to 54, i.e. `CHANGES.md`; the new and edited files in `Matlab/Work-in-Progress/GI` (logger profiles, GPS ranges, roughness, the two-file inversion, the flag for the propagation model, the scripts for the results); KRAKEN as a MEX function with its source and the MEX files for Apple silicon and Linux (`Matlab/KrakenMex`); the Linux `kraken.exe` (`ReferenceCode/bin/glnxa64`); the figures of the range-dependent run, of the two-file run, and of the MFP tests (`GI/Results`, `MFP/Results`); and three result files (53 MB): the range-dependent run and the two-file run with its intermediate file of 10,000 samples. Not in the repository: the measurements (`Matlab/Data`) and ORCA (`Matlab/Orca`), both in `.gitignore`. As before, the account name on the server and the details of other projects are left out of this file.

**What a new person needs**

- Data: `Matlab/Data` (SIO files, CTD and XBT casts) is not in the repository (`.gitignore`); get it from Florian Meyer.
- KRAKEN: the repository has `kraken.exe` for Apple silicon, Intel Macs, and Linux (x86-64) in `ReferenceCode/bin`, and KRAKEN as a MEX function for Apple silicon and Linux in `Matlab/KrakenMex` (the setting of the main scripts since 2026-11-19; build and requirements in its `README.md`, Section 50). On a Mac, a binary that came through a download or a file sync can carry the macOS quarantine flag; KRAKEN is then killed at start (exit code 137). Replacing the file with a locally built copy, or removing the flag, fixes it.
- MATLAB: the inversion scripts need the Parallel Computing Toolbox (`parpool`, `parfor`). `showResultsData.m`, `checkEffectiveSnapshots.m`, and `checkHeldOutWindows.m` do not.
- Server: access to `meyer01.ucsd.edu` needs an account and either the jump host of the university (Section 48) or the UCSD VPN; ask Florian Meyer.

| Commit | Date | Content |
|---|---|---|
| `e568966` | 2026-10-14 | Fixes in `ReferenceCode`, SBCEX22 inversion code, first MFP script, LFM script, `.gitignore` |
| `1706288` | 2026-10-14 | MFP rewritten, sound speed profile selection, seabed tuning, data moved to `Matlab/Data` |
| `f0957d7` | 2026-11-11 | Inversion: integrated-out noise variance, setup of the MFP at 21:00, known parameters, ordering fix |
| `cc0741f` | 2026-11-15 | Results script, continuous-gradient inversion, snapshot analysis, joint inversion with held-out frames, range-dependent inversion with an EOF profile, MFP with the MAP environment, diagnostics, this file (Sections 7 to 25) |
| commit of 2026-11-20 (see `git log`) | 2026-11-20 | Range-dependent run and its evaluation, ORCA as a second model (code only), logger profiles and ship data, tests of range dependence and of the geometry, roughness, joint inversion of the two files at 1 km and its results, KRAKEN as a MEX function and the flag for the propagation model, proposal for the next inversion (Sections 26 to 54) |

Findings and the reasons behind the choices are in `Matlab/Work-in-Progress/NOTES.md`.

## 1. Reference code (`ReferenceCode`, SBCEX17 inversion)

All changes are in `e568966`. The sampler and the forward model are otherwise as in the original code.

**KRAKEN binary**

- `kraken.exe` moved to `bin/maca64/` (Apple silicon); an Intel build was added in `bin/maci64/`.
- `getModesSBCEXP17.m` uses the binary for the current platform (`computer('arch')`) and falls back to `kraken.exe` on the MATLAB path.

**KRAKEN failures**

- The old mode file is deleted before each run, so a failed run cannot be read as valid output.
- A non-zero exit code or a missing mode file raises the error `SBCEX:krakenFailed`.
- A binary that cannot be executed raises `SBCEX:krakenUnavailable`. `getNextSample.m` passes this error on instead of counting it as a failed proposal. Before, the sampler caught every error and kept running.
- Scratch files are removed with `delete` instead of a shell call.

**SNR of the synthetic data** (`main14L2.m`, `main17L2H.m`)

- Before, `scenario.likelihoodConstantSNR` was used both as the SNR in dB for generating the data and as the linear factor in the likelihood.
- Now `scenario.snrDb` is the SNR in dB, and `scenario.likelihoodConstantSNR = 10^(snrDb/10) + 1` is the linear factor that `evaluateLogLikelihood.m` expects.

**Memory and parallel pool** (`main14L2.m`, `main17L2H.m`, `mainData14L2.m`)

- Only the current proposal covariances are kept, plus a history with one entry per 1000 samples (`proposalCovarianceHistory`, `covarianceHistoryInterval`). Before, one covariance per sample and temperature was stored.
- The workers receive only the last sample instead of the whole chain (the whole initial block is passed once, when the adaptation starts).
- The pool size is limited to the workers the machine has.

**Other**

- `SBCEXP17Template88.env`: 1001 instead of 101 receiver depths over 0-100 m (0.1 m grid for the modes).
- `showResults.m`: the results file is set in one variable; the MAP estimate is the sample with the highest posterior (likelihood times prior), not the highest likelihood.
- `getReceiverDepthOffset.m`: the comment on the tilt sign was corrected (positive tilt leans the array away from the source). No code change.
- The scratch files `SBCEXP17Compute1.*` were removed from the repository.

Not changed: `getCovariancesDifferences.m` in `ReferenceCode` still has the ordering problem described in Section 3.4. It matters when parameters are set as known and the fast initialization is used (`main17L2H.m`).

## 2. LFM beamforming (`Matlab/LFM/LFMBeamformingFreeSpace.m`)

Changed in `e568966`.

- The array is the SBCEX22 VLA, defined from the water depth: 16 hydrophones, 3.75 m spacing, hydrophone 1 at 7.25 m above the seafloor.
- New switch `scenario.useSphericalWavefronts`: exact arrival time and amplitude at each hydrophone, or the plane-wave model the beamformer assumes.
- The chirp has no taper, as in SBCEX22.
- The script prints a note when the hydrophone spacing exceeds the alias-free limit and when the source is inside the far-field range.
- Fractional delay filter: the Lagrange filter is now centred on its stencil, and negative delays are handled.

## 3. SBCEX22 inversion (`Matlab/Work-in-Progress/GI`)

New in `e568966`: the reference code adapted to SBCEX22 (VLA1, 200 m contour, source tow Track 8, five tonals at 503-1253 Hz).

### 3.1 Model and state

One sediment layer with linear gradients over a half-space; 14 parameters:

| # | Parameter | # | Parameter |
|---|---|---|---|
| 1 | Source range | 8 | Layer density, bottom |
| 2 | Source depth | 9 | Layer attenuation, top |
| 3 | Array tilt | 10 | Layer attenuation, bottom |
| 4 | Water depth | 11 | Layer thickness |
| 5 | Layer speed, top | 12 | Half-space speed |
| 6 | Layer speed, bottom | 13 | Half-space density |
| 7 | Layer density, top | 14 | Half-space attenuation |

### 3.2 New files

| File | Purpose |
|---|---|
| `main14L1H.m` | Inversion of synthetic data |
| `mainData14L1H.m` | Inversion of the recorded data |
| `getPressuresFromStateSBCEXP22.m` | Forward model: state to pressure at the hydrophones |
| `getModesSBCEXP22.m` | Runs KRAKEN once for all frequencies; modes are computed exactly at the hydrophone and source depths; measured sound speed profile down to the current water depth |
| `writeKrakenEnvSBCEXP22.m` | Writes the KRAKEN environment file (no template file) |
| `getPressureSBCEXP22.m` | Modal sum |
| `getReceiverGeometrySBCEXP22.m` | Hydrophones at fixed heights above the seafloor, so the array moves with the water depth (see `WaterDepthOptions.md`) |
| `getDataMatrixesSBCEXP22.m` | Cross-spectral matrices of the tonals for one averaging window of an SIO file, processed as in the MFP |
| `getSensitivitySBCEXP22.m` | Sensitivity of the Bartlett value to each parameter |
| `sioread.m` | Reader for the SIO files |

### 3.3 Files taken from the reference code

- Unchanged: `checkAndFixCovarianceMatrix.m`, `checkPriorUniform.m`, `evaluateLogPrior.m`, `getPriorCovariance.m`, `getProposalCovariance.m`, `performSwap.m`, `readModes.m`.
- Only the forward-model call changed: `getCovariancesSampling.m`, `getNextSample.m`.
- `printOutputStrings.m`: rewritten; the parameter names come from the fields of `scenario.prior`.
- `showResults.m`: as in Section 1, with the SBCEX22 file names.
- `evaluateLogLikelihood.m`, `getCovariancesDifferences.m`: see Section 3.4.

### 3.4 Changes in `f0957d7`

**Likelihood with unknown noise variance** (`evaluateLogLikelihood.m`)

- New third noise model, selected by `scenario.likelihoodConstantSNR = nan`: the noise variance of each tone is unknown and integrated out with a prior that is uniform in its logarithm.
- The result is log L = -N * sum over tones of log(1 - B), with N = 16 hydrophones and B the Bartlett value of the tone.
- Reason: the fixed SNR factor of 10 was about 5 times too sharp for the Bartlett values of 0.4-0.5 reached on the data.
- The two earlier noise models (fixed SNR, known noise variance) are unchanged.

**Fast initialization** (`getCovariancesDifferences.m`)

- It now receives `mcmc`. When the noise variance is integrated out, the linearization uses the assumed SNR `mcmc.fastInitSNR`.
- Ordering fix: the covariance matrix passed to `eig` was not exactly symmetric, so the eigenvalues were not returned in sorted order. The sampler relies on this order to skip the directions of the known parameters. With six known parameters, six of the eight proposal directions pointed along known parameters. The matrix is now symmetrized before `eig`.

**Setup of the MFP at 21:00** (`mainData14L1H.m`)

- Data: file `RAVA01.22147210000.sio`, first averaging window of `MFP.m` (15 snapshots, 5.2 s). The cross-spectral matrices are identical to those of `MFP.m`.
- Sound speed profile: XBT #11 with the salinity of CTD #16, read with `readSoundSpeedCastMFP.m`. The file `SBCEXP22_ssp_ctd020.mat` is no longer used.
- Source range prior: centred on the GPS range of the window (1030 m; ship positions at the launches of XBT #9-11, layback 180 m), standard deviation 100 m.
- Reference state for the plots: MFP seabed, GPS range, source depth 125 m.
- `main14L1H.m` uses the same sound speed profile, source position, and seabed for the synthetic data.

**Known parameters** (both scripts)

- The densities and attenuations of the layer and the half-space (state entries 7-10, 13, 14) have limited sensitivity at this range and are kept at the values of the MFP environment (`scenario.isKnown`).
- Eight parameters remain unknown: source range, source depth, tilt, water depth, layer speed top and bottom, layer thickness, half-space speed.

### 3.5 Checks

- Likelihood: the three noise models were tested against direct evaluation, and the closed form against numerical integration.
- At the MFP peak (1030 m, 125 m) the forward model of the inversion gives the same Bartlett value as `MFP.m` (0.405).
- Short end-to-end runs of `mainData14L1H.m` (45 samples) on the Mac and on the server: the known parameters stay fixed, the stored likelihoods match a recomputation, and no proposal fails in KRAKEN.

## 4. Matched-field processing (`Matlab/Work-in-Progress/MFP`)

New in `e568966`, rewritten and extended in `1706288`. Based on the original MFP code by Yongsung Park in `Matlab/MFP`, which is unchanged.

| File | Purpose |
|---|---|
| `MFP.m` | Bartlett MFP of the five tonals for six files of JD 147 in 5 s windows; compares the peaks with the GPS source position |
| `tuneSoundSpeedMFP.m` | Selects the sound speed profile among the CTD and XBT casts and estimates the layback of the source |
| `tuneBottomMFP.m` | Tunes the layer and half-space parameters by MFP |
| `getToneCrossSpectraMFP.m` | Cross-spectral matrices of the tonals for consecutive windows of a file |
| `computeModesMFP.m`, `computeReplicasMFP.m`, `writeKrakenEnv.m` | KRAKEN modes and replica vectors |
| `readSoundSpeedCastMFP.m` | Sound speed profile from a CTD or XBT cast |
| `getSourceTrackMFP.m` | Source range from the ship's GPS track and the layback |
| `Results/` | Figures and result files of the three scripts |

Settings of `MFP.m` that the inversion shares: XBT #11 with the salinity of CTD #16, layback 180 m, water depth 200 m, and the seabed from the shelf-break cores (layer 1550-1620 m/s, 1.60-1.80 g/cm^3, 0.30-0.55 dB/(m kHz), 1.5 m; half-space 1650 m/s, 1.85 g/cm^3, 0.65 dB/(m kHz)).

Open point: `tuneBottomMFP.m` still uses the earlier profile, CTD #20. Its tuned values in `Results/tunedBottom.mat` are not used by `MFP.m` or the inversion.

## 5. Repository

- `.gitignore` is new: Finder metadata, KRAKEN scratch files, failed-proposal files, and `Matlab/Data/`.
- The data (SIO files, CTD and XBT casts) are kept locally in `Matlab/Data/` and are not in the repository.
- `Matlab/Work-in-Progress/NOTES.md` and `Matlab/Work-in-Progress/GI/WaterDepthOptions.md` are new.

## 6. Inversion run on `meyer01.ucsd.edu`

Started on 2026-11-11 at 17:03 PST: `mainData14L1H.m` at commit `f0957d7`, unmodified (70,000 samples, 10 temperatures, 10 workers). In all server paths of this file, `<user>` stands for the account name on the server.

**Setup**

- Working directory: `/var/tmp/<user>/GI-SBCEX22`, a clone of the repository. The home directory could not be used because `/home` on the server was full when the run was set up (30 MB free).
- Data: the 21:00 SIO file and the CTD and XBT casts were copied into `Matlab/Data` of the clone.
- KRAKEN: Linux binary in `ReferenceCode/bin/glnxa64/kraken.exe`, copied from `~/matlab/at/Kraken/kraken.exe` on the server. It is not in the repository.
- MATLAB R2022a. Its preferences and parallel pool files are kept under `/var/tmp/<user>` (set with `MATLAB_PREFDIR`), also because `/home` was full.

**Checks before the start**

- The log-likelihoods of 12 states from the short run on the Mac were recomputed on the server; they agree to 1e-14.
- The sound speed profile, the GPS source range, and the selected tone frequencies are identical to those on the Mac.
- A short end-to-end run on the server (45 samples, 10 temperatures, 10 workers) finished without errors.

**Launch command**

```
cd /var/tmp/<user>/GI-SBCEX22/Matlab/Work-in-Progress/GI
MATLAB_PREFDIR=/var/tmp/<user>/matlab-prefdir setsid nohup nice -n 5 matlab -batch "mainData14L1H" > /var/tmp/<user>/inversionLog.txt 2>&1 < /dev/null &
```

**Timing** (from the short run on the server)

- One forward run takes 0.17 s (0.28 s on the Mac); one sample takes 1.9 s.
- The initialization is serial. In this run it took about 1.2 hours (about 17 minutes for each of the three lowest temperatures, less for the higher ones); sampling started at about 18:17 PST.
- Sampling rate in this run: 28 samples per minute (2.1 s per sample), measured over the first 200 samples. At this rate the 70,000 samples take about 42 hours, so the run should finish around midday on 2026-11-13 (PST).
- The parallel pool closes after 30 minutes without work, which happened during the initialization. The first `parfor` loop reopened it with the default size of 12 workers.

**Output**

- Log: `/var/tmp/<user>/inversionLog.txt` (it will grow to about 0.6 GB). The last lines show the current sample number.
- Results: `resultsDataTmp.mat` after every 10,000 samples and `resultsData.mat` at the end, both in the `GI` folder of the clone.
- The process ID is in `/var/tmp/<user>/inversion.pid`.

**Outcome**

- The server rebooted for a kernel update on 2026-11-12 at 16:01 PST and stopped the run at sample 38,601. The log has no errors or warnings up to that point.
- The last intermediate file, `resultsDataTmp.mat` (written 2026-11-12 at 11:11 PST), holds the first 30,000 samples. It was copied to `Matlab/Work-in-Progress/GI` on Florian Meyer's MacBook. `resultsData.mat` with the sensitivity analysis was not written.
- Florian Meyer decided that 30,000 samples are enough; the run was not repeated.
- The script cannot continue from an intermediate file.
- The server has rebooted on a Thursday at about 16:00 PST roughly once a month (2026-09-10, 2026-10-15, 2026-11-12). Plan long runs around this.
- Files in `/var/tmp` that are not touched for 30 days are deleted automatically, so results have to be copied from the server.

## 7. Results of the first inversion (30,000 samples)

### 7.1 `showResultsData.m` (new)

`Matlab/Work-in-Progress/GI/showResultsData.m` shows the results of `mainData14L1H.m` and `mainData14L1HContinuous.m`; `showResults.m` is unchanged. Set `resultsFile` at the top. It removes the first 5,000 samples and

- prints the MAP estimate, mean, standard deviation, and 95% interval of each unknown parameter,
- prints the posterior correlation coefficients of the unknown parameters,
- prints the sound speed of the seabed at several depths,
- prints the Bartlett value of each tone for the MAP estimate, the mean, and the MFP reference state, together with the cap (this step reads the SIO file and runs KRAKEN; `isShowFit = false` skips it),
- draws the marginal posteriors, the sound speed profile of the seabed, the sample traces, and the correlation matrix.

Coupled parameters (`scenario.coupling`) are copies of other parameters and are left out.

### 7.2 Estimates

Samples 5,001 to 30,000 at temperature 1. The chain is stationary from the first few thousand samples on. The densities and attenuations were kept at the MFP values. The reference is the MFP environment.

| Parameter | MAP | Mean | Std | 95% interval | Reference |
|---|---|---|---|---|---|
| Source range (m) | 1010.5 | 1009.0 | 13.9 | 982 to 1037 | 1030.4 |
| Source depth (m) | 123.67 | 123.58 | 0.89 | 121.9 to 125.4 | 125 |
| Tilt (deg) | 0.132 | 0.130 | 0.098 | -0.06 to 0.32 | 0 |
| Water depth (m) | 199.60 | 199.42 | 1.29 | 196.9 to 202.0 | 200 |
| Layer speed, top (m/s) | 1541.3 | 1563.5 | 64.5 | 1463 to 1716 | 1550 |
| Layer speed, bottom (m/s) | 1708.4 | 1670.3 | 99.4 | 1486 to 1839 | 1620 |
| Layer thickness (m) | 3.00 | 2.61 | 1.33 | 0.58 to 4.89 | 1.5 |
| Halfspace speed (m/s) | 1588.9 | 1589.8 | 21.8 | 1577 to 1642 | 1650 |

The log-likelihood at the MAP estimate is 54.02 (sample 20,017).

- Resolved: source range, source depth, tilt, water depth, and the halfspace speed (about 1589 m/s, below the 1650 m/s of the MFP environment).
- Not resolved: the layer thickness (flat over its prior) and the two layer speeds (broad). Their MAP values carry little weight.
- Strongest posterior correlations: source range with source depth (0.88) and with water depth (0.81); source depth with layer speed at the top (-0.54); the two layer speeds (-0.48). All others are below 0.5 in magnitude.

### 7.3 Bartlett values of each tone

| Tone | MAP | Mean | Reference | Cap |
|---|---|---|---|---|
| 503 Hz | 0.443 | 0.441 | 0.537 | 0.781 |
| 653 Hz | 0.583 | 0.585 | 0.432 | 0.784 |
| 803 Hz | 0.582 | 0.540 | 0.428 | 0.784 |
| 1003 Hz | 0.440 | 0.448 | 0.401 | 0.646 |
| 1253 Hz | 0.371 | 0.361 | 0.199 | 0.532 |
| Mean | 0.484 | 0.475 | 0.399 | 0.705 |

The cap is the largest Bartlett value any replica can reach: the largest eigenvalue of the cross-spectral matrix divided by its trace. It is below 1 because the matrix is an average over 15 snapshots that differ from each other (noise and changes of the signal during the 5.2 s); a single replica matches only one direction of that matrix. The MAP estimate reaches 69% of the cap on average.

Using fewer snapshots raises the cap but not the fit: with unit-norm snapshots, the Bartlett value of the averaged matrix is the mean of the Bartlett values of the single snapshots.

### 7.4 Why the layer interface is not resolved

- The fit does not depend on the thickness. In thickness bins from 0.5 to 5 m, the mean log-likelihood is 49.9 to 50.0 and the best log-likelihood is 53.5 to 54.0 in every bin.
- The data do not require a speed jump at the interface: halfspace speed minus the speed at the bottom of the layer is -80 +/- 105 m/s.
- What is resolved is the sound speed against depth below the seafloor:

| Depth (m) | Median (m/s) | 95% interval (m/s) |
|---|---|---|
| 0 | 1555 | 1463 to 1716 |
| 0.5 | 1579 | 1517 to 1708 |
| 1 | 1591 | 1543 to 1724 |
| 2 | 1593 | 1564 to 1757 |
| 3 | 1589 | 1569 to 1771 |
| 5 and deeper | 1586 | 1577 to 1642 |

- The densities are fixed at 1.6 to 1.8 in the layer and 1.85 in the halfspace, so the interface has almost no density contrast by construction.
- The forward model is KRAKEN (`kraken.exe`: real modes, attenuation as a perturbation, fluid seabed without shear).

### 7.5 Offset from the GPS range

The estimated source range is 20 m (inversion) to 26 m (peaks of the 12 windows, Section 9) shorter than the GPS range, about 2 to 2.5%. Florian Meyer's assessment (2026-11-13): this is not surprising, for two reasons.

- **Tow cable:** the source is towed behind the ship on a cable whose length is not well determined. The GPS range assumes a layback of 180 m.
- **Mirage effect:** G. L. D'Spain, J. J. Murray, W. S. Hodgkiss, N. O. Booth, and P. W. Schey, "Mirages in shallow water matched field processing," J. Acoust. Soc. Am. 105(6), 3245-3265 (1999). When the replicas assume a range-independent water depth but the depth changes along the path, the MFP peak stays coherent and moves in range and depth instead of breaking up. In their data (replicas for 200 m, true depth decreasing to 100 m) the estimated range and depth became increasingly larger than the true values, by up to 100%. The offsets do not depend on the array geometry. A model with adiabatic modes in an ideal waveguide explains them, and through the effective depth of the waveguide it also covers mismatch of the seabed.

The relations below are the ideal-waveguide argument written out here; they were not copied from the paper and should be checked against it. With water depth D(r) along the path, replica depth D0, true range r, and true source depth z:

- estimated range = D0^2 times the integral of dr / D(r)^2 from 0 to r, about r * (D0 / mean depth)^2,
- estimated source depth = z * D0 / (depth at the source).

A source in shallower water than assumed appears farther away and deeper; a source in deeper water appears closer and shallower.

For this data set:

- A range that is 2 to 2.5% short corresponds to a mean water depth along the path that is 1 to 1.25% (2 to 2.5 m) larger than the depth of the model, if the layback were exact.
- The posterior correlations of the first inversion follow these relations. Range against water depth: predicted slope 2r/D = 10.1 m per m, posterior 8.7 m per m (correlation 0.81). Source depth against range: predicted z/(2r) = 0.061, posterior 0.056 (correlation 0.88).
- The range prior (GPS range, standard deviation 100 m) is wide enough to allow the offset.
- Because the seabed acts through the effective depth, a change of bathymetry along the path can also bias the seabed parameters, not only range and depth.

## 8. Continuous-gradient inversion (`mainData14L1HContinuous.m`, new)

A copy of `mainData14L1H.m` in which the sound speed has no jump at the interface. The thickness is then the depth at which the gradient ends.

- `scenario.coupling = [6,12]`: the speed at the bottom of the layer is set equal to the halfspace speed. The coupling mechanism was already in the sampler (`getNextSample.m`, `getCovariancesSampling.m`) and had not been used. Seven parameters remain unknown; the seabed ones are the speed at the top of the layer, the thickness, and the halfspace speed.
- The prior interval of the bottom speed is that of the halfspace speed (1550 to 1900 m/s).
- The first sample (prior mean) is made consistent with the coupling.
- 30,000 samples. Output: `resultsDataContinuous.mat`, with `resultsDataContinuousTmp.mat` after 10,000 and 20,000 samples.

**Check:** a short run (2 temperatures, 60 samples, without the two parallel-pool lines because the MacBook has no Parallel Computing Toolbox) finished without errors or failed proposals. The two coupled speeds are equal in every sample, the six known parameters do not move, and the proposal covariance has seven directions with nonzero variance.

**Run on `meyer01.ucsd.edu`:** started on 2026-11-13 at 22:37 PST in the clone of Section 6, to which the new script was copied (the clone is otherwise at `f0957d7`).

```
cd /var/tmp/<user>/GI-SBCEX22/Matlab/Work-in-Progress/GI
MATLAB_PREFDIR=/var/tmp/<user>/matlab-prefdir setsid nohup nice -n 5 matlab -batch "mainData14L1HContinuous" > /var/tmp/<user>/inversionContinuousLog.txt 2>&1 < /dev/null &
```

- Log: `/var/tmp/<user>/inversionContinuousLog.txt`; process ID in `/var/tmp/<user>/inversionContinuous.pid`.
- At 23:11 PST the initialization was running and the log had no errors or warnings.
- Expected duration: about 1 hour of initialization and about 18 hours of sampling (rate of the first run).

## 9. Effective number of snapshots (`checkEffectiveSnapshots.m`, new)

The likelihood is log L = -N * sum over tones of log(1 - B) with N = 16 hydrophones. It has no factor for the number of snapshots, so the 15 averaged snapshots count as one. With K independent snapshots the exponent would be K*N. The snapshots overlap by 50%, and model error is the same in every snapshot, so the effective K is between 1 and 15.

`checkEffectiveSnapshots.m` estimates it in two ways from the samples of the first inversion and all 12 averaging windows of the 21:00 file.

**Residual analysis.** The best-fitting replica at the MAP environment is subtracted from each snapshot. The effective count is the mean residual power divided by the power of the mean residual: 1 if the residual is the same in every snapshot, about 15 if it is independent noise.

| Tone | Effective count | Residual correlation, adjacent snapshots | Four snapshots apart |
|---|---|---|---|
| 503 Hz | 1.5 | 0.96 | 0.63 |
| 653 Hz | 1.8 | 0.92 | 0.54 |
| 803 Hz | 2.2 | 0.92 | 0.43 |
| 1003 Hz | 2.3 | 0.89 | 0.31 |
| 1253 Hz | 2.6 | 0.80 | 0.23 |

Medians over the 12 windows. Over all tones and windows the median is 2.1 (quartiles 1.7 and 2.6). The residual is mostly model error.

**Scatter between windows.** With the MAP environment fixed, the peak in range and source depth was located in each window and its scatter compared with the posterior standard deviation given the other parameters.

| | Posterior std (count 1) | Scatter over 12 windows | Implied count |
|---|---|---|---|
| Range minus GPS range | 6.2 m | 4.4 m | 2.0 |
| Source depth | 0.57 m | 0.45 m | 1.6 |

From differences of consecutive windows (which removes slow drifts) the scatter is 3.6 m and 0.33 m, which implies about 3. This check measures repeatability only; an error common to all windows does not show (the peaks are 17 to 31 m short of the GPS range in all windows, 26 m on average).

**Conclusion:** an effective count of 2 (exponent 32). Not applied. To apply it, multiply the log-likelihood by the count (one factor in `evaluateLogLikelihood.m`, set in the main script) and rerun, or reweight the existing samples.

## 10. Noise variance of each tone (not implemented)

The current likelihood integrates the noise variance of each tone out with a prior that is uniform in its logarithm. Sampling it explicitly with the same prior gives the same posterior for all other parameters; the gain is the posterior of the noise variance itself.

With the noise variance v of a tone as a parameter, log L = -K*N*log(v) - K*trace(R)*(1 - B)/v. The branch for a known noise variance in `evaluateLogLikelihood.m` omits the first term and cannot be used for an unknown variance. With unit-norm snapshots trace(R) = 1 and the best-fitting v is (1 - B)/N.

Options, in order of effort:

1. Post-processing: for each stored sample, compute B of each tone with one forward run and draw v from its conditional distribution (inverse gamma). No new inversion.
2. A Gibbs step in the sampler that draws the five variances after each sweep. No additional forward runs.
3. Five additional state entries (log v) proposed by the existing sampler. Least code, most forward runs.

The effective number of snapshots (Section 9) should be settled first, because it affects all parameters.

## 11. Continuous-gradient inversion: first 20,000 samples

The table is from the first 20,000 samples (local copy `resultsDataContinuous_run20261113T2237_20000samples.mat`, deleted on 2026-11-14 after the complete file was downloaded; it was the intermediate file `resultsDataContinuousTmp.mat` of the run started 2026-11-13 22:37 PST, written 2026-11-14 07:02 PST; the name carries the start time of the run and the number of samples). `showResultsData.m` lists the local results files in a comment and puts the file name into the figure titles. Burn-in 5,000 samples.

| Parameter | MAP | Std | First run MAP |
|---|---|---|---|
| Source range [m] | 1010.4 | 14.2 | 1010.5 |
| Source depth [m] | 123.61 | 0.87 | 123.67 |
| Tilt [deg] | 0.118 | 0.100 | 0.132 |
| Water depth [m] | 199.61 | 1.27 | 199.60 |
| Speed at the seafloor [m/s] | 1572 | 53 | 1541 |
| Thickness [m] | 1.75 | 1.32 | 3.00 |
| Halfspace speed [m/s] | 1588.3 | 15.5 | 1588.9 |

- Complete run (30,000 samples, `resultsDataContinuous_run20261113T2237_30000samples.mat`, burn-in 5,000): the MAP is the same sample (18,413), so all MAP values and Bartlett values are identical; standard deviations: range 14.0 m, source depth 0.87 m, tilt 0.099 deg, water depth 1.27 m, speed at the seafloor 53 m/s, thickness 1.33 m, halfspace speed 14.9 m/s.
- Fit unchanged: mean Bartlett value at the MAP 0.482 (first run 0.484), log-likelihood 53.68 (54.02).
- The thickness is still not resolved (95% interval 0.6 to 4.9 m). The halfspace speed and the profile below 2 m are tighter (1586 to 1587 m/s, 95% interval about 1570 to 1630 m/s).
- Reason in one sentence: the data are consistent with nearly the same speed above and below the interface, and the low-grazing-angle modes sense an average of the top few metres, so moving the interface changes the field by far less than the model mismatch.

## 12. How to improve the fit: assessment (2026-11-14)

Based on the JASA paper on SBCEX17 (Meyer, Hodgkiss, Saucan, JASA 159, 4736, 2026), the notes of another inversion project of Florian Meyer (not in this repository; called "the other project" below), and one sensitivity test. Those notes were sampled, not read completely.

### 12.1 Sensitivity test

At the MAP of the continuous-gradient run one item was changed, then source range, source depth, tilt, and water depth were fitted again with a local optimizer (`fminsearch`, 250 evaluations; the seabed was not fitted again). The script was a scratch file and is not in the repository.

| Change | Mean Bartlett, geometry fixed | After fitting the geometry | Range / water depth [m] |
|---|---|---|---|
| None (XBT 11) | 0.482 | 0.483 | 1010 / 199.5 |
| XBT 10 | 0.272 | 0.460 | 1021 / 204.8 |
| Mean of XBT 10 and 11 | 0.396 | 0.485 | 1028 / 203.8 |
| XBT 9 | 0.154 | 0.265 | 1010 / 204.7 |
| CTD 16 | 0.207 | 0.319 | 1049 / 206.6 |
| XBT 11 moved 3 m down / up | 0.426 / 0.419 | 0.473 / 0.474 | 1007 / 200.2, 1008 / 199.1 |
| XBT 11 + 1 m/s below 100 m | 0.287 | 0.482 | 995 / 198.0 |
| Halfspace speed 1650 m/s | 0.358 | 0.438 | 1014 / 199.1 |
| Halfspace speed 1750 m/s | 0.319 | 0.353 | 1016 / 199.3 |
| Speed at the seafloor 1500 m/s | 0.439 | 0.467 | 1023 / 199.8 |
| Thickness 4.5 m | 0.479 | 0.480 | 1012 / 199.7 |

- The sound speed profile of the water changes the field more than any seabed change tried.
- The geometry absorbs much of a profile change: the choice of cast moves the range by up to 40 m and the water depth by up to 7 m at almost the same fit. Some fitted water depths are outside the prior interval of the inversion (195 to 205 m).
- No cast gives more than 0.485. A smooth change of the profile alone does not close the gap to the cap of 0.70.

### 12.2 Model changes, in order of priority

1. Sound speed profile of the water with 2 to 3 EOF coefficients as unknowns, the EOFs computed from all casts of the cruise. Expected: a small gain of fit; mainly, range, water depth, and seabed no longer absorb the profile error. In the other project two EOF coefficients raised the fit from 0.674 to 0.693.
2. Range dependence with adiabatic modes (two water depths, as in the SBCEX17 paper): only together with several windows. One window cannot separate a bottom slope from range and depth (Section 7.5); the other project found a gain of 0.01 or less.
3. More layers: no. The data cannot place one interface.
4. Trans-dimensional inversion: no, for the same reason. In the SBCEX17 paper it raised the fit at the cost of wider posteriors, and there the layering was real.
5. Shear: no. In sand it acts as a small additional loss at low grazing angles and would require a different forward model. The other project needed it because of its seabed.

Before any of these: invert several windows jointly and judge each change on held-out windows (Section 13). In the other project the MAP of a single frame was over-fitted (0.79 on its frame, 0.60 on held-out frames), and all seabed model families reached the same fit on ten frames.

### 12.3 Longer range (21:20 file)

As a second data point, not as a replacement. For: more interaction with the seabed; XBT 11 was launched at 21:33, 3.4 km east of the VLA, and may describe the path at 21:20 better than the path at 21:00. Against: errors of profile and bathymetry grow with range, most at 1253 Hz. First step: MFP on the 21:20 file with the current MAP environment. Not done.

## 13. Joint inversion of several windows with held-out windows (new, 2026-11-14)

### 13.1 Model

- Windows 1, 3, 5, 7, 9, 11 of the 21:00 file are inverted together (`scenario.windowIndexesFit`); windows 2, 4, ..., 12 are held out (`scenario.windowIndexesHeldOut`). Window 1 is the reference window.
- One environment, one source depth, and one tilt for all windows. State entry 1 is the source range of the reference window. The range of window w is this range plus the GPS range difference to the reference window (`scenario.sourceRangeOffsets`: 0, 10.8, 21.5, 32.3, 43.1, 53.8 m). An error of the layback that is the same in all windows is therefore still estimated. The unknowns are the same 7 as in `mainData14L1HContinuous.m`.
- Likelihood: sum over all windows and tones of the existing term, i.e. an unknown noise variance for each window and tone, and all windows counted as independent. Model errors that repeat from window to window make the posterior too narrow (Section 9); the effective number of snapshots is still 1 per window.
- Cost: the modes do not depend on the range, so each proposal needs one KRAKEN run as before (0.2 s per proposal on the MacBook).

### 13.2 Code

- `mainData14L1HJoint.m` (new, copy of `mainData14L1HContinuous.m`): window settings, GPS ranges of all 12 windows (`scenario.sourceRangesGPSFile`), data matrices of the windows stacked along the third dimension (all tones of window 1, all tones of window 2, ...). Saves `resultsDataJointTmp` (every 10,000 samples) and `resultsDataJoint`. The sensitivity analysis at the end uses the reference window only.
- `getPressuresFromStateSBCEXP22.m`: if `scenario.sourceRangeOffsets` is set, the pressure is returned for each offset, with the columns ordered as the data matrices. Without the field the result is unchanged (checked: identical to the first columns). `evaluateLogLikelihood.m`, `getNextSample.m`, and the other sampler functions are unchanged; they treat every column as one tone.
- `checkHeldOutWindows.m` (new): evaluates the MAP estimate and 100 posterior samples of any results file (joint or single window) on all 12 windows, with the ranges tied to GPS as above and nothing fitted to the held-out windows. Prints Bartlett values of each window and tone, the cap, the log-likelihood per window, and the means over the fit and the held-out windows; one figure.
- `showResultsData.m`: the table of Bartlett values averages over the windows of a joint run. Output for the existing files unchanged.

Local checks (MacBook, no Parallel Computing Toolbox, so not the complete script): the setup up to the prior runs; the joint log-likelihood at the MAP of the continuous-gradient run is 277.8, equal to the sum of the six windows in Section 13.3; six sampler steps ran without error with the coupling kept.

### 13.3 Baseline: the single-window inversion on the other windows

`checkHeldOutWindows.m` on the first 20,000 samples of the continuous-gradient run (inverted window: 1). The MAP is the same sample in the complete run, so the MAP values hold for it as well.

| Window | Mean Bartlett at the MAP | Cap | Log-likelihood |
|---|---|---|---|
| 1 (inverted) | 0.482 | 0.705 | 53.7 |
| 2 | 0.442 | 0.751 | 47.1 |
| 3 | 0.408 | 0.713 | 43.1 |
| 4 | 0.343 | 0.659 | 34.3 |
| 5 | 0.428 | 0.656 | 46.0 |
| 6 | 0.443 | 0.673 | 48.8 |
| 7 | 0.478 | 0.742 | 52.3 |
| 8 | 0.492 | 0.736 | 55.1 |
| 9 | 0.454 | 0.753 | 48.6 |
| 10 | 0.431 | 0.705 | 45.6 |
| 11 | 0.340 | 0.650 | 34.0 |
| 12 | 0.367 | 0.682 | 38.0 |

- Held-out windows (11): mean Bartlett 0.421, mean log-likelihood 44.8 (inverted window: 0.482 and 53.7). Posterior samples: 0.410 (std 0.019) held out, 0.458 (0.014) on the inverted window.
- Per tone, held out against inverted: 503 Hz 0.512 / 0.450, 653 Hz 0.443 / 0.575, 803 Hz 0.433 / 0.578, 1003 Hz 0.389 / 0.438, 1253 Hz 0.326 / 0.371.
- The numbers to beat for the joint run and for every later model change: 0.421 and 44.8 on held-out windows. The held-out set of the joint run is windows 2, 4, ..., 12; for these six the single-window MAP gives 0.420 and 44.8.

### 13.4 Run on the server

Started 2026-11-14 at 11:02 PST, after the continuous-gradient run had ended (both write KRAKEN scratch files with the same names in the same folder, so they cannot run at the same time). `mainData14L1HJoint.m`, `getPressuresFromStateSBCEXP22.m`, `checkHeldOutWindows.m`, and `showResultsData.m` were copied to the clone on the server (checksums equal to the local files).

```
cd /var/tmp/<user>/GI-SBCEX22/Matlab/Work-in-Progress/GI
MATLAB_PREFDIR=/var/tmp/<user>/matlab-prefdir setsid nohup nice -n 5 matlab -batch "mainData14L1HJoint" > /var/tmp/<user>/inversionJointLog.txt 2>&1 < /dev/null &
```

Log: `/var/tmp/<user>/inversionJointLog.txt`; process id in `/var/tmp/<user>/inversionJoint.pid`. 75 s after the start the run was in the initialization with no errors or warnings in the log. Expected duration about 12 to 13 hours; the server reboots about once a month (Section 6).

### 13.5 Status on 2026-11-14 at 17:26 PST and first 10,000 samples (preliminary)

Status of the run:

- Running, no errors or warnings in the log. Sample 10,161 of 30,000 at 17:26 PST; `resultsDataJointTmp.mat` (10,000 samples) was written at 17:21 PST.
- The initialization of the proposal covariances (`getCovariancesSampling`) took 2 h 17 min, until 13:19 PST (5,530 steps for temperature 1; in the single-window runs it was short, since their total run time matches the sampling speed). The pool of 10 workers reached its idle timeout during this time, and MATLAB opened a new pool of 12 workers at the first sampling step; this caused no error.
- Sampling speed: 2,480 samples/h from 13:19 to 17:21 PST, about 2,200 samples/h at 17:25 PST. Expected end between about 01:30 and 02:30 PST on 2026-11-15.
- Check at 20:31 PST: sample 17,139, no errors or warnings, 2,260 samples/h since 17:26 PST; expected end about 02:15 PST on 2026-11-15, intermediate file with 20,000 samples about 21:45 PST.
- Check on 2026-11-15 at 08:27 PST: the run has ended. `resultsDataJoint.mat` (30,000 samples, 22,379,732 bytes, md5 `b5a17bfac81603798622ea8c69345b4f`) was written at 02:16 PST; sampling took 46,535 s (12 h 56 min) after the initialization, 15 h 14 min in total; no errors or warnings in the log. `resultsDataJointTmp.mat` on the server holds the first 20,000 samples (21:48 PST). The file was downloaded the same morning (Section 13.6). No inversion process of this project is left on the server; the jobs of the other project still run.
- Two jobs of another project of the same account run on the server since 15:11 and 17:07 PST (22 processes). Load 25 on 32 cores. They were not touched.

First 10,000 samples (5,000 after burn-in). The intermediate file is on this Mac as `Matlab/Work-in-Progress/GI/resultsDataJointTmp_run20261114T1102_10000samples.mat` (checksum equal to the file on the server); `showResultsData.m` and `checkHeldOutWindows.m` point to it. Evaluated with `checkHeldOutWindows.m`:

| | single-window MAP (Section 13.3) | joint MAP, 10,000 samples |
|---|---|---|
| held-out windows 2, 4, ..., 12: mean Bartlett | 0.420 | 0.448 |
| held-out windows: logL per window | 44.8 | 48.6 |
| fit windows 1, 3, ..., 11: mean Bartlett | | 0.455 |
| fit windows: logL per window | 46.3 | 49.4 |
| window 1: mean Bartlett | 0.482 | 0.462 |

- Joint MAP (sample 5,602, joint logL 296.4 against 277.8 at the single-window MAP): range of window 1 1013 m, source depth 124.0 m, tilt 0.14 deg, water depth 199.9 m, speedTop 1549 m/s, thickness 3.5 m, speedH 1588 m/s. Geometry and half-space speed agree with the single-window MAP (Section 11).
- Fit and held-out windows are almost equal (0.455 and 0.448), so the joint estimate is not fitted to the noise of its windows. Window 1 loses 0.02, which is the part of the single-window fit that did not carry over to other windows.
- Standard deviations (single-window run in parentheses): range 6.7 m (14.0), source depth 0.38 m (0.87), tilt 0.038 deg (0.099), water depth 0.58 m (1.27), speedTop 9 m/s (53), thickness 0.81 m (1.33), speedH 3.9 m/s (14.9). They are too small if the model error is the same in all windows (Section 13.1).
- Thickness: 95% interval 2.0 to 4.95 m, mean 3.8 m. It leans against the upper prior bound of 5 m. If this holds for the complete run, the bound has to be raised in the next run.
- The mean Bartlett value stays far below the cap of 0.70. The joint inversion gives a more reliable estimate of the same model; it does not remove the model error (Section 12).
- 100 posterior samples: held-out 0.444 (std 0.004), 48.1 logL per window (0.5); fit 0.451 (0.002), 48.8 (0.3).

Output of `showResultsData.m` for the same file:

- Convergence: the traces are stationary from about sample 500; the means of the first and second half of the samples after burn-in agree (e.g., range 1012.9 and 1013.3 m, speedH 1588.7 and 1588.1 m/s, thickness 3.87 and 3.76 m).
- Sound speed of the seabed, median (95% interval): 1552 m/s (1532 to 1567) at the seafloor, 1562 (1553 to 1572) at 1 m, 1572 (1566 to 1582) at 2 m, 1581 (1575 to 1589) at 3 m, 1588 (1581 to 1596) at 5 m. The speed at each depth is resolved within about 10 to 20 m/s, although the thickness as a parameter is not: the data resolve a gradient of about 10 m/s per m in the first metres.
- Thickness: the histogram rises towards the upper prior bound of 5 m and is cut there; 24% of the samples are above 4.5 m.
- Posterior correlations: range and source depth 0.92, range and water depth 0.89 (as in the single-window runs), speedTop and thickness 0.56, thickness and speedH 0.47, source depth and speedTop -0.54.
- Bartlett values, mean over the six fit windows, MAP (reference state of MFP): 0.492 (0.521) at 503 Hz, 0.464 (0.299) at 653 Hz, 0.484 (0.351) at 803 Hz, 0.455 (0.307) at 1003 Hz, 0.378 (0.214) at 1253 Hz; mean 0.455 (0.338), cap 0.703. At 503 Hz the reference state fits better than the MAP; the other four tones decide the estimate.

### 13.6 Complete run: 30,000 samples (2026-11-15)

The complete result file is on this Mac as `Matlab/Work-in-Progress/GI/resultsDataJoint_run20261114T1102_30000samples.mat` (22,379,732 bytes, md5 `b5a17bfac81603798622ea8c69345b4f`, equal to the file on the server). `showResultsData.m` and `checkHeldOutWindows.m` point to it; the file with the first 10,000 samples stays in the list of `showResultsData.m`. Both scripts ran on it without errors. 25,000 samples after burn-in.

| parameter | MAP (sample 27,613) | mean | std | 95% interval |
|---|---|---|---|---|
| source range of window 1 [m] | 1012.8 | 1013.5 | 6.7 | 1000.1 to 1026.7 |
| source depth [m] | 123.98 | 124.00 | 0.37 | 123.26 to 124.74 |
| tilt [deg] | 0.131 | 0.142 | 0.037 | 0.071 to 0.213 |
| water depth [m] | 199.89 | 199.97 | 0.58 | 198.81 to 201.12 |
| speedTop [m/s] | 1553.6 | 1551.8 | 9.3 | 1531.1 to 1567.9 |
| thickness [m] | 3.84 | 3.80 | 0.81 | 2.01 to 4.94 |
| speedH [m/s] | 1588.0 | 1588.3 | 3.9 | 1580.9 to 1596.4 |

- The complete run confirms the first 10,000 samples (Section 13.5); no number changes by more than a fraction of its standard deviation. Joint logL at the MAP 296.49 (296.42 after 10,000 samples).
- Held-out windows at the MAP: mean Bartlett 0.448, 48.7 logL per window (single-window MAP: 0.420 and 44.8, Section 13.3). Fit windows: 0.455 and 49.4. Cap 0.70. 100 posterior samples: held-out 0.443 (std 0.004) and 48.0 (0.6); fit 0.451 (0.003) and 48.8 (0.4).
- Per tone, mean over the six fit windows, MAP (reference state of MFP): 0.493 (0.521), 0.465 (0.299), 0.484 (0.351), 0.454 (0.307), 0.377 (0.214).
- Convergence: the means of the first and second half after burn-in agree (range 1013.3 and 1013.6 m, water depth 199.95 and 199.99 m, speedTop 1551.9 and 1551.8 m/s, thickness 3.82 and 3.79 m, speedH 1588.3 and 1588.2 m/s).
- Thickness: still leans against the upper prior bound of 5 m (23.7% of the samples above 4.5 m). The bound has to be raised if this parameter is to be reported; it is left at 5 m in the range-dependent run so that only the water profile differs.
- Sound speed of the seabed, median (95% interval): 1553 m/s (1531 to 1568) at the seafloor, 1562 (1552 to 1573) at 1 m, 1572 (1566 to 1582) at 2 m, 1581 (1575 to 1589) at 3 m, 1588 (1581 to 1596) at 5 m.
- Posterior correlations: range and source depth 0.92, range and water depth 0.90, speedTop and thickness 0.56, thickness and speedH 0.47, source depth and speedTop -0.54.

## 14. Is the water sound speed profile range dependent? (2026-11-14)

Hypothesis of Florian Meyer: the profile of the water depends on range, and this is why data and model do not match well. Two short tests on the first 10,000 samples of the joint run (Section 13.5). The test scripts were in the scratch folder of the session and are not in the repository; the method is described here. No code of the repository was changed.

### 14.1 Where the mismatch of the data sits

For the joint MAP and the six fit windows, the replica was compared with the eigenvector of the largest eigenvalue of each cross-spectral matrix.

| tone [Hz] | 503 | 653 | 803 | 1003 | 1253 |
|---|---|---|---|---|---|
| squared correlation of replica and eigenvector | 0.60 | 0.62 | 0.66 | 0.66 | 0.65 |
| same, phase error only (amplitudes of the data) | 0.69 | 0.72 | 0.74 | 0.81 | 0.82 |
| same, amplitude error only (phases of the data) | 0.85 | 0.84 | 0.87 | 0.81 | 0.82 |
| rms phase error over the array [deg] | 55 | 45 | 45 | 43 | 48 |
| second eigenvalue / trace | 0.11 | 0.14 | 0.15 | 0.15 | 0.22 |

- The mismatch does not grow with frequency.
- No hydrophone carries the mismatch: the shares of the residual are 3.6 to 11.2% (equal shares: 6.25%), and leaving one hydrophone out changes the squared correlation by 0.013 or less. Phase and amplitude errors of a hydrophone differ from tone to tone. So it is not a channel, gain, or position error of the array.
- The phase error over the array is not smooth: a polynomial of degree 3 over the height explains 10 to 31% of it. Tilt or a curved array do not explain it.
- The residual repeats between windows at 503 Hz (correlation 0.65 between adjacent fit windows; 0.22 for random vectors) and less at the other tones (0.26 to 0.40).

### 14.2 The casts

| cast | time (UTC, 2022-05-27) | distance to the VLA | difference to XBT 11: rms, max [m/s] |
|---|---|---|---|
| CTD 16 | 13:12 | 490 m | 5.09, 15.3 |
| XBT 9 | 19:32 | 4636 m | 4.50, 14.5 |
| XBT 10 | 20:33 | 644 m | 2.75, 9.3 |
| XBT 11 (used in the inversion) | 21:33 | 3380 m | |

XBT 10 and XBT 11 bracket the 21:00 file in time (27 min before, 33 min after). They are 4.0 km apart and differ by 2.75 m/s rms (mean +1.9 m/s above 100 m, +0.65 m/s below). The water changed by this much within 4 km and one hour.

### 14.3 Synthetic test

Fields of the six fit windows were simulated at the joint MAP with a changed environment. Range dependence was simulated with adiabatic modes: mode shapes at the source from the environment at the source, mode shapes at the receivers from the environment at the array, mean of the wavenumbers. The range-independent model with XBT 11 was then fitted to the simulated field (all 7 unknowns, `fminsearch` from the true state with 450 evaluations, likelihood of the inversion with white noise for a cap of 0.70). The table gives the squared correlation of replica and simulated field, mean over tones and windows. The value of the data is 0.64 (Section 14.1).

| simulated field | at the true state | after the fit | per tone after the fit |
|---|---|---|---|
| wrong profile, no range dependence: XBT 10 | 0.50 | 0.85 | 0.92 0.90 0.86 0.81 0.78 |
| range dependent: XBT 10 at the source, XBT 11 at the array | 0.52 | 0.67 | 0.69 0.70 0.74 0.58 0.65 |
| range dependent: XBT 11 at the source, XBT 10 at the array | 0.65 | 0.73 | 0.79 0.75 0.74 0.65 0.71 |
| range dependent: 26% of the difference XBT 10 minus XBT 11 at the source (linear change between the casts) | 0.87 | 0.89 | 0.90 1.00 0.89 0.83 0.84 |
| range dependent: thermocline 5 m deeper at the source | 0.62 | 0.78 | 0.82 0.86 0.70 0.74 0.80 |
| seafloor 5 m deeper at the source | 0.56 | 0.88 | 0.98 0.82 0.87 0.93 0.79 |
| seafloor 10 m deeper at the source | 0.20 | 0.84 | 0.95 0.81 0.86 0.83 0.77 |
| seafloor 10 m shallower at the source | 0.17 | 0.81 | 0.84 0.86 0.74 0.77 0.83 |

- A wrong profile that does not depend on range is mostly absorbed by the other parameters (0.85; water depth -4.9 m, speedTop +17 m/s, source depth +1.3 m), and what is left grows with frequency. The data do not show this.
- A range-dependent profile is absorbed least (0.67 to 0.78), and what is left is about equal at all tones, as in the data. The fit pays with biased estimates (range -27 m, water depth -4.5 m, speedH +24 m/s in the first case).
- The size matters: the mismatch of the data needs a difference between source and array as large as the difference between XBT 10 and XBT 11, or a thermocline that is several metres deeper at one end. A linear change between the two casts gives only 26% of this over the path and leaves 0.89. So the hypothesis needs structure shorter than the cast spacing (front, internal waves); the casts cannot confirm this.
- A seafloor depth that differs by 5 to 10 m between source and array is absorbed better (0.81 to 0.88).
- Limits: the fit is a local search, so the values after the fit are lower bounds; the simulated truth is adiabatic (no mode coupling); the test shows that the hypothesis is consistent with the data in size and in signature, not that it is the only explanation.
- **Correction (2026-11-14, found while building the inversion of Section 16):** the two rows with XBT 10 at one end and XBT 11 at the other are not reliable. The adiabatic sum pairs the modes of the two ends by their index. For these two profiles the modes do not correspond one to one: the correlation of the paired mode shapes, weighted with their contribution to the field, is 0.84 at 503 Hz and 0.47 at 1253 Hz, and at 1253 Hz 60 of 109 modes have their best match at another index. The profile has two ducts (sound speed minimum near 40 m, maximum near 150 m), and their modes change their order. The rows with a moderate difference are valid (26% of the difference: correlation 0.95 to 0.98; thermocline 5 m deeper: 0.85 to 0.94). What remains of the test: a moderate range dependence of the profile (thermocline row, 0.78) is absorbed less than a wrong profile without range dependence (0.85) and less than a seafloor depth difference (0.81 to 0.88). The statement that a difference as large as XBT 10 minus XBT 11 is needed is withdrawn; the test cannot say what such a difference does.

### 14.4 Consequence

The EOF profile (open point 8) should be range dependent from the start: EOF coefficients at the source and at the array, adiabatic modes with two KRAKEN runs per proposal (as in the SBCEX17 paper, there for the water depth). A single set of coefficients for the whole path is expected to gain little, because the present model already absorbs that kind of error. The joint windows fit this model: all windows share both profiles. Judge it on the held-out windows (Section 13.3).

## 15. EOFs of the water sound speed: first look at the casts (2026-11-14)

A short look at the casts as an ensemble for EOFs, as preparation of open point 8. Scratch script, not in the repository; nothing implemented.

**Ensemble.** Casts of the shelf-break site: XBT 9 to 36 and CTD 15 to 28 (2022-05-26 to 2022-05-31, 0.6 to 16 km from the VLA). 34 of the 42 casts reach 195 m (23 XBT, 11 CTD); the others were taken in shallower water (144 to 192 m). Grid 0 to 200 m in steps of 1 m.

**Salinity of the XBTs.** The salinity of the CTDs is 33.2 to 35.6 PSU. A salinity computed from the temperature (cubic fit to all CTDs) has an rms error of 0.52 PSU (0.64 PSU if a CTD is predicted from the other CTDs). The present approach, the salinity profile of CTD 16 as a function of depth, has 0.34 PSU (0.41 m/s). So the present approach stays; the sound speed of an XBT has an error of about 0.4 m/s from the salinity alone.

**Variance.** Standard deviation over the casts: 6.3 m/s at 20 m, 4.1 m/s at 40 m, 2.6 m/s at 60 m, 1.4 m/s at 100 m, 0.7 to 0.95 m/s below 120 m. Share of the variance of EOF 1 to 6: 62, 12, 9, 5, 3, 2% (83% with three, 90% with five). EOF 1 is confined to the upper 80 m.

**How well the EOFs represent a cast** (rms error in m/s, EOFs built without the cast):

| number of EOFs | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| all casts, each left out in turn (median) | 2.45 | 1.64 | 1.45 | 1.14 | 1.04 | 0.99 | 0.91 |
| XBT 10 minus XBT 11 | 3.00 | 2.85 | 1.91 | 1.60 | 1.53 | 1.52 | 1.44 |

**Effect on the field.** Squared correlation of the field of the joint MAP with and without one standard deviation of a coefficient (state fixed, mean over tones and windows): EOF 1 0.37, EOF 2 0.89, EOF 3 0.73, EOF 4 0.82, EOF 5 0.95. The first four EOFs all matter; the coefficients have to be resolved to a small part of their standard deviation.

**Differences between casts are not vertical displacements.** The best uniform vertical shift of XBT 11 reduces its difference to XBT 10 from 2.75 to 2.72 m/s rms. The casts differ in the water itself (largest differences at the surface and at 160 to 180 m), so a displacement of the thermocline is not a substitute for EOFs here.

**Suggested construction.**

1. Ensemble: the 34 casts above; salinity of the XBTs as now.
2. Profile: measured reference cast (XBT 11) plus EOFs, c(z) = c_ref(z) + sum of a_k e_k(z). The EOFs are the left singular vectors of the casts minus their mean, each scaled with the standard deviation of its coefficient, so that a_k is in units of standard deviations. The reference keeps the fine structure that few EOFs cannot represent.
3. Three or four EOFs. Uniform prior of about -2 to 2 for each coefficient.
4. Range dependence (Section 14): coefficients at the source and at the array, adiabatic modes, two KRAKEN runs per proposal. This adds 6 to 8 unknowns. Control run: the same coefficients at both ends. The difference of the two runs on the held-out windows tests the hypothesis of Section 14.
5. Number of EOFs: decided on the held-out windows, not by the share of the variance.

**Limits.** The casts are hours and kilometres apart. Their EOFs describe the variability at these scales and are dominated by the upper 60 m. Three EOFs leave about 1.1 m/s of a cast and half of the change from XBT 11 to XBT 10. The field reacts to less than that, so a gain is expected but not a complete fit.

**To check first.** The readme of the cruise data lists temperature loggers (`TLoggers_HOBO`); their data are not in `Matlab/Data`. (Answered in Section 22: the loggers were on the VLA, one beside each hydrophone.) If loggers were on or near the VLA mooring, they give the profile at the array at the time of the data (the coefficients at the array could then be fixed) and an ensemble for the variability over minutes, which the casts do not have.

## 16. Range-dependent inversion with an EOF profile of the water (new, 2026-11-14)

Requested by Florian Meyer after Sections 14 and 15: an inversion with a sound speed profile of the water that depends on range, built with the information available now (the temperature loggers are being looked into separately). Set up and tested locally; not started on the server.

### 16.1 Model

- Everything of the joint inversion (Section 13) stays: six fit windows of the 21:00 file, GPS range differences, one environment, seabed with coupling speedBottom = speedH, same priors (thickness still 0.5 to 5 m, so that only the water profile changes).
- Profile at the array: XBT 11 + EOFs * a. Profile at the source: profile at the array + EOFs * d. The state has 20 entries: the 14 of the joint inversion, then `sspArray1..3` (a) and `sspDifference1..3` (d). Coefficients are in units of their standard deviation over the casts.
- EOFs as in `MFP/tuneSoundSpeedMFP.m` (which already refined XBT 11 with EOFs for MFP): the 18 casts along the 200 m contour, CTD 15, 16, 18, 20, 21 and XBT 9 to 21, XBTs with the salinity of CTD 16. This replaces the ensemble of 34 casts of Section 15, which included casts over the slope. Share of the variance of EOF 1 to 6: 69, 11, 8, 4, 2, 2%. One standard deviation of EOF 1, 2, 3 is 2.16, 0.88, 0.73 m/s rms over depth; EOF 1 lives in the upper 80 m (5.6 m/s at 20 m). XBT 10 minus XBT 11 has the coefficients 0.33, 2.0, -1.8; three EOFs leave 1.46 of its 2.75 m/s rms.
- Three EOFs. Prior of a: -2 to 2 for each coefficient (as `eofBound` in `tuneSoundSpeedMFP.m`). Prior of d: -0.25 to 0.25, -0.5 to 0.5, -1 to 1 (Section 16.3).
- Pressure: adiabatic modes as in `ReferenceCode/getPressureAdiabatic.m`. Mode shapes at the receivers from the profile at the array, mode shapes at the source from the profile at the source, mean of the wavenumbers of both ends (also in the amplitude factor; the reference code uses the wavenumber at the receiver there, the difference is negligible). Water depth and seabed do not depend on range. A proposal with d different from zero needs two KRAKEN runs.
- Unknowns: 13 (7 of the joint inversion, 3 a, 3 d). Control run (`isRangeDependent = false`): d fixed at zero, 10 unknowns, one KRAKEN run per proposal. The hypothesis of Section 14 is supported if the range-dependent run fits the held-out windows better than the control run; both are compared with the joint run (Section 13.5).

### 16.2 Code

- `mainData14L1HRangeDependent.m` (new, copy of `mainData14L1HJoint.m`): settings `isRangeDependent`, `eofBoundArray`, `eofBoundsDifference` (one entry per EOF; its length is the number of EOFs); 20,000 samples; results in `resultsDataEOFRangeDependent.mat` or `resultsDataEOFRangeIndependent.mat` (control), intermediate file with `Tmp` at the end every 10,000 samples.
- `getSoundSpeedEOFsSBCEXP22.m` (new): EOFs from a list of casts, each scaled with the standard deviation of its coefficient, sign fixed (largest element positive). The casts, their mean, and the variance shares are stored in `scenario.ssp.eofInfo`.
- `getPressuresFromStateSBCEXP22.m`: if `scenario.sspIndexesArray` is set, the profile is built from the state and, for d different from zero, the second KRAKEN run and the adiabatic sum are used. Without the field the result is unchanged.
- `getModePairingSBCEXP22.m` (new): check of the adiabatic modes for a state (Section 16.3).
- `getCovariancesSampling.m`: the loop over the temperatures is now a `parfor` loop. The temperatures are independent and use their own KRAKEN files, so the result is the same kind of estimate; only the random numbers differ. Reason: in the joint run this initialization ran serially for 2 h 17 min (Section 13.5); with 13 unknowns and two KRAKEN runs it would take about 16 h serially. The first temperature took about 15% of the serial time in the joint run, so about 2 to 3 h are expected in parallel. This also affects `mainData14L1H.m`, `mainData14L1HContinuous.m`, and `mainData14L1HJoint.m` if they are run again.
- `showResultsData.m`: for these results also a table and a figure of the profile of the water at the array and at the source, and the check of the adiabatic modes for the MAP and 20 posterior samples. `checkHeldOutWindows.m` works without changes.

### 16.3 Limit of the adiabatic modes and the prior of the differences

The adiabatic sum pairs the modes of the two ends by their index. The profile here has two ducts (sound speed minimum near 40 m, maximum near 150 m). If the profiles of the two ends differ too much, the modes of the ducts change their order, the pairs no longer correspond, and the pressure is wrong (this affected two rows of Section 14.3, see the correction there). `getModePairingSBCEXP22.m` measures this: the correlation of the paired mode shapes over the water column, weighted with the contribution of each mode to the field. At the joint MAP (per tone, 503 to 1253 Hz):

| difference between the ends | rms [m/s] | correlation of the paired mode shapes | squared correlation of the fields with and without the difference |
|---|---|---|---|
| EOF 1: 0.25 | 0.54 | 0.98 0.96 0.94 0.94 0.90 | 0.77 |
| EOF 1: 0.5 | 1.08 | 0.93 0.88 0.82 0.76 0.64 | 0.41 |
| EOF 1: 1 | 2.16 | 0.73 0.59 0.43 0.29 0.14 | not valid |
| EOF 2: 0.5 | 0.44 | 1.00 0.99 0.98 0.98 0.97 | 0.92 |
| EOF 2: 1 | 0.88 | 0.98 0.95 0.93 0.92 0.88 | 0.73 |
| EOF 3: 1 | 0.73 | 0.99 0.99 0.98 0.98 0.97 | 0.91 |
| EOF 3: 2 | 1.45 | 0.98 0.96 0.94 0.92 0.88 | 0.69 |
| all three at the bounds 0.25, 0.5, 1 (worst signs) | | 0.95 0.90 0.86 0.81 0.73 | |
| all three at half the bounds | | 0.99 0.97 0.95 0.95 0.92 | |

- The prior of d (0.25, 0.5, 1) keeps each coefficient alone at a correlation of 0.90 or more. In the corners of the prior the two highest tones are no longer reliable (0.81 and 0.73). `showResultsData.m` therefore reports the correlation for the MAP and for posterior samples; a result with values of about 0.9 and less should not be trusted.
- Inside these bounds the field still changes a lot (squared correlation 0.77 for 0.25 of EOF 1), so the model has room to act.
- For comparison: XBT 10 minus XBT 11 scaled from 4.0 km to the 1 km path is 0.08, 0.5, -0.45, inside the bounds.
- If the data ask for a larger difference (posterior of d at the bounds), adiabatic modes are not enough. The next step would then be coupled modes with one vertical interface between source and array (two range-independent segments), which needs the mode shapes of both ends over the whole depth.

### 16.4 Tests

Forward model (at the joint MAP of Section 13.5):

- Coefficients zero: identical to the model of the joint inversion (difference 0).
- Coefficients at the array only: identical to the old model with that profile (difference 0).
- With a difference: equal to an adiabatic sum computed directly in the test (difference 1e-18); 0.35 s per evaluation on this Mac, 0.18 s without a difference.

Sampler (temporary copies of the main script without the parallel pool, 2 temperatures, 10 samples, initialization with 2 acceptances per dimension, proposal covariance from the samples after 4 samples):

- Range-dependent run: 13 unknowns, no errors or warnings; initialization, sampling, swaps, the change to the adaptive covariance, the sensitivity at the end, and the results file work.
- Control run: 10 unknowns, the three differences stay at zero, no errors or warnings.
- `showResultsData.m` and `checkHeldOutWindows.m` run on the test result of the range-dependent run (all tables, five figures, check of the adiabatic modes). The numbers of this test mean nothing (10 samples).
- Not tested: the `parfor` loop of `getCovariancesSampling.m` with a real pool. This Mac has no Parallel Computing Toolbox; here the loop runs serially. The code analyzer reports nothing for the file.

### 16.5 Run on the server (range-dependent run started on 2026-11-15, see Section 23; control run not started)

Each run should get its own folder: KRAKEN writes its files into the current folder under names that are the same for all runs, and the results are written there too. Two runs in the same folder at the same time disturb each other (Section 13.4). With separate folders the range-dependent run, the control run, and the joint run can run at the same time. The files to copy to the clone on the server first: `mainData14L1HRangeDependent.m`, `getSoundSpeedEOFsSBCEXP22.m`, `getModePairingSBCEXP22.m`, `getPressuresFromStateSBCEXP22.m`, `getCovariancesSampling.m`, `showResultsData.m`, `checkHeldOutWindows.m` (the last one is still the version of 2026-11-14 there).

```
mkdir -p /var/tmp/<user>/runs/eofRangeDependent
cd /var/tmp/<user>/runs/eofRangeDependent
MATLAB_PREFDIR=/var/tmp/<user>/matlab-prefdir setsid nohup nice -n 5 matlab -batch "addpath('/var/tmp/<user>/GI-SBCEX22/Matlab/Work-in-Progress/GI'); mainData14L1HRangeDependent" > /var/tmp/<user>/inversionEOFRangeDependentLog.txt 2>&1 < /dev/null &
```

For the control run: set `isRangeDependent = false` in a copy of the script on the server (or edit and start one run after the other), use another folder and another log file. If both are started at the same time, give the second one its own `MATLAB_PREFDIR`, because two MATLAB sessions that open a pool with the same preference folder at the same moment can disturb each other. Starting from a folder other than the code folder and two runs at the same time have not been tried on the server.

Expected duration (estimates from the speed of the joint run, 0.21 s per KRAKEN run and proposal with 10 workers): range-dependent run 13 proposals with two KRAKEN runs per sample, about 650 samples per hour, 31 h for 20,000 samples plus 2 to 3 h of initialization; control run 10 proposals with one KRAKEN run, about 1,700 samples per hour, 12 h plus about 1 h. Each run uses 10 workers; the server has 32 cores and the jobs of the other project used 22 of them on 2026-11-14.

### 16.6 First indication on the data: local search (not a result of the inversion)

Before spending the server time, a local search (`fminsearch`, 700 evaluations per stage, scratch script) was run on the six fit windows from the joint MAP of Section 13.5, within the priors of Section 16.1. The held-out windows were not used in the search.

| state | fit windows: logL | fit: mean Bartlett | held out: logL per window | held out: mean Bartlett |
|---|---|---|---|---|
| joint MAP, 10,000 samples (no EOFs) | 296.4 | 0.455 | 48.6 | 0.448 |
| EOFs, same profile at both ends (10 unknowns) | 302.8 | 0.462 | 50.1 | 0.458 |
| EOFs, range dependent (13 unknowns, two stages) | 305.0 | 0.465 | 50.1 | 0.458 |

- States found: same profile: range 1023 m, source depth 124.4 m, water depth 200.9 m, speedTop 1487 m/s, thickness 1.7 m, speedH 1586 m/s, a = (-0.31, 0.20, 1.62). Range dependent: almost the same, a = (-0.33, 0.13, 1.81), d = (0.03, 0.15, -0.65). The adiabatic modes are valid there (correlation of the paired mode shapes 0.99 at all tones).
- The EOF coefficients give a small gain that carries over to the held-out windows (0.448 to 0.458). The differences between the ends add 2.2 to the log-likelihood of the fit windows with three more parameters and nothing on the held-out windows.
- With the EOFs free, the seabed estimate changes (speedTop 1549 to 1487 m/s, thickness 3.5 to 1.7 m). Water profile and seabed are coupled; the third coefficient at the array goes towards its bound of 2.
- This is a local search from one starting point. It finds the nearest maximum only, and it says nothing about the posterior. The inversion with parallel tempering can find other maxima. As it stands, this first look does not support the hypothesis of Section 14 within the limits of this model (three EOFs, differences inside the range where adiabatic modes are valid): the fit stays far below the cap of 0.70.


## 17. Bathymetry between the array and the source: should the water depth depend on range? (2026-11-15)

Question of Florian Meyer before the range-dependent run of Section 16 is started. Scratch scripts, not in the repository; no code of the repository was changed. **The test on the data (17.3) is incomplete**, see there.

### 17.1 Bathymetry that is available

- In `Matlab/Data` there is only the 3-arc-second grid of NOAA (Coastal Relief Model): `Data/processed/AIS/AIS_shelfbreak/matlab_mfiles/shelfbreakMap/bathy/SBCEX21bathy.mat` (`lat`, `lon`, `d` in m, negative down; spacing 92.5 m north by 71.1 m east; values in steps of 0.1 m, smooth).
- Not in `Matlab/Data`: the 25-m bathymetry (`HighRes_Bathy`), and the echo sounder and multibeam data of the ship (Knudsen 12 kHz and 3.5 kHz, EM122 and EM710; `ReadMe_cruise_data_legC.txt`: available on request). The CTD files have no altimeter channel, and the deepest samples of the XBT files are not bottom depths.

### 17.2 What the grid shows

- Around the path the seafloor is a plane to within 0.7 m rms: slope 0.0152 (0.87 deg), downslope towards 190 deg (south). The isobaths run along 100/280 deg.
- The course of the ship from XBT 10 to XBT 11 is 101.5 deg, 1.8 deg off the isobaths. The tow track follows the isobaths, as planned.
- VLA1 is about 200 m upslope (north) of the tow track. The path from the array to the source therefore runs slightly downslope (bearing 112 deg for all 12 windows of the 21:00 file).
- Grid depth at VLA1 201.7 m; at the source 205.3 m for all 12 windows. **The source end is 3.6 m deeper than the array end**; mean along the path 1.9 m deeper than at the array; the seafloor between them is a straight ramp to within 0.1 m of the grid (0.2 deg along the path).
- Check of the grid: the inversion gives 199.97 m (std 0.58 m) at the array and the nominal depth is 200 m, so the grid is about 1.7 m deeper there (tide and accuracy of the grid). CTD 16 (490 m from VLA1, downslope) reached 204.7 m where the grid has 208.1 m, which is consistent.
- Accuracy of the difference (my estimate): it is the slope times the distance of the source across the isobaths (about 220 m). 50 m of error in that distance gives 0.8 m, 20% of error in the slope 0.7 m. The grid cannot show features smaller than about 100 m.

### 17.3 Effect on the field and test on the data

Model of the test: adiabatic modes as in Section 16.1, with the water depth at the source = water depth at the array + delta (second KRAKEN run with the deeper water column; receivers stay referenced to the seafloor at the array).

Squared correlation of the field with and without delta, joint MAP of Section 13.6, state fixed, mean over the 12 windows:

| delta [m] | 503 Hz | 653 Hz | 803 Hz | 1003 Hz | 1253 Hz | mean |
|---|---|---|---|---|---|---|
| -2 | 0.91 | 0.96 | 0.89 | 0.75 | 0.78 | 0.85 |
| +1 | 0.99 | 0.99 | 0.88 | 0.96 | 0.96 | 0.95 |
| +2 | 0.97 | 0.93 | 0.81 | 0.87 | 0.84 | 0.88 |
| +3.6 (grid) | 0.92 | 0.77 | 0.68 | 0.67 | 0.49 | 0.70 |
| +5 | 0.86 | 0.63 | 0.54 | 0.48 | 0.28 | 0.56 |

The field is sensitive to a difference of the size of the grid value: it is not a negligible effect.

Local search on the six fit windows from the joint MAP (`fminsearch`, as in Section 16.6; finds the nearest maximum only):

| state | fit windows, logL | fit, mean Bartlett | held out, logL per window | held out, mean Bartlett |
|---|---|---|---|---|
| joint MAP, same depth at both ends | 296.5 | 0.455 | 48.7 | 0.448 |
| same depth, after the search | 296.6 | 0.455 | 48.7 | 0.448 |
| delta = 3.6 m, other values at the MAP | 220.2 | 0.362 | 36.0 | 0.353 |
| delta = 3.6 m, other values re-optimized (two searches) | 282.3 | 0.441 | 46.7 | 0.435 |

- With delta fixed at the grid value the search reaches a lower likelihood than without it (282.3 against 296.6; range 1020 m, source depth 125.7 m, water depth at the array 199.0 m). So in this test the data do not ask for the grid value. This is a lower bound, since the search is local.
- **Not done:** the search with delta free and the likelihood as a function of delta. The MATLAB job was stopped at 08:39 PST because it kept Florian Meyer from opening MATLAB (see 17.4).

### 17.4 Note on MATLAB jobs on this Mac

A `matlab -batch` job started from the terminal registers with macOS as the running MATLAB application without a window. While it runs, a click on the MATLAB icon only activates this job and no window appears. A second instance can be opened with `open -n /Applications/MATLAB_R2026b.app` (standard macOS behaviour; not tried here). Tell the user before starting MATLAB jobs on this Mac that run longer than a few seconds.

## 18. MFP with the MAP estimate of the inversion as environment (2026-11-15)

Request of Florian Meyer: the figure `MFP/Results/MFP_files.png` again, with replicas from the MAP estimate of the environment.

### 18.1 Code

- `MFP/MFP.m`: new settings `inversionResultsFile` and `inversionBurnIn`. With the name of a results file in `GI`, the MAP estimate (as in `showResultsData.m`) replaces water depth, array tilt, and seabed (layer and halfspace); the figures are saved with the ending `_MAP` and carry a second title line. With `''` the script works as before. The setting is left at `resultsDataJoint_run20261114T1102_30000samples`. Results with EOF coefficients (Section 16) are refused.
- `MFP/MFP.m`: the sound speed profile of the water now has the water depth as its last point (`unique([(0:1:floor(waterDepth))';waterDepth])`), which KRAKEN needs for a water depth that is not a whole number. For 200 m the grid is unchanged.
- `MFP/MFP.m` and `MFP/computeModesMFP.m`: if the Acoustics Toolbox is not on the path or at `atPath`, the script uses the KRAKEN binary of the repository (`ReferenceCode/bin`) and the mode reader of the inversion (`GI/readModes.m`). On the MacBook the toolbox is not installed at `atPath`, and the `kraken.exe` of the local copy of the toolbox is an Intel build that does not run there (no Rosetta); `MFP.m` did not run on the MacBook before this change.

### 18.2 Checks

- Original environment (`inversionResultsFile = ''`, scratch copy, figures written to the scratch folder): the values of `MFP_files.png` of 2026-10-14 are reproduced to two decimals in all six panels, so the fallback gives the same result as the toolbox on the other Mac.
- MAP environment, 21:00 file: the MFP value at the source is 0.461 in window 1 (grid point 1020 m, 124 m); the inversion gives 0.462 at its MAP source position (1012.8 m, 123.98 m). The 12 windows agree with `checkHeldOutWindows.m` to within 0.02 (the MFP searches range and depth on a 10 m by 1 m grid for each window).

### 18.3 Result

New figures: `MFP/Results/MFP_files_MAP.png`, `MFP_frequencies_MAP.png`, `MFP_track_MAP.png`. The figures of 2026-10-14 are untouched. Mean over the 12 windows of each file of the Bartlett value at the source position (highest value within 50 m of the GPS range and 100 to 140 m depth), and number of windows whose peak is at the source:

| file | GPS range | original environment | MAP environment | cap | peak at source, original | peak at source, MAP |
|---|---|---|---|---|---|---|
| 19:30 | 5.0 km | 0.144 | 0.144 | 0.667 | 1 of 12 | 0 of 12 |
| 20:30 | 1.0 km | 0.429 | 0.397 | 0.664 | 12 of 12 | 12 of 12 |
| 21:00 | 1.0 km | 0.385 | 0.450 | 0.702 | 12 of 12 | 12 of 12 |
| 21:10 | 1.7 km | 0.232 | 0.242 | 0.689 | 12 of 12 | 12 of 12 |
| 21:20 | 2.4 km | 0.186 | 0.187 | 0.702 | 12 of 12 | 12 of 12 |
| 21:30 | 3.0 km | 0.196 | 0.203 | 0.724 | 5 of 12 | 1 of 12 |
| all | | 0.262 | 0.271 | 0.691 | 54 of 72 | 49 of 72 |

- The MAP environment raises the file it was estimated from (21:00: 0.385 to 0.450) and nothing else. The 20:30 file, at the same range, is lower with it (0.429 to 0.397); the files at 1.7 to 3 km change by 0.01 or less; at 21:30 the peak is at the source in fewer windows.
- So the gain of the inversion does not carry over to the other files. The held-out windows of Section 13 are from the same file and the same path; they cannot show this.
- Not examined: why. Candidates are that the estimate absorbs an error that belongs to the path of the 21:00 file (water column or bathymetry along the path, Sections 14 and 17), or that the environment differs between the paths.

## 19. Fewer snapshots per averaging window: effect on the cap (2026-11-15)

Question of Florian Meyer: would fewer snapshots per window raise the cap, and would that make sense? Short test on the 21:00 file (scratch script, not in the repository; no code changed). Cross-spectral matrices from `getToneCrossSpectraMFP.m` with K snapshots per window; replicas from the MAP estimate of the joint run (Section 13.6) as in Section 18. "Fixed track": source at the GPS range minus 17.6 m (the MAP offset) and at 124 m depth. "Refitted": highest value on a grid of 1 m by 0.5 m around the track, in each window. White noise: simulated, independent snapshots.

| K | window | windows | cap | MAP replica, fixed track | MAP replica, refitted | cap of white noise |
|---|---|---|---|---|---|---|
| 1 | 0.7 s | 182 | 1.000 | 0.455 | 0.476 | 1.000 |
| 2 | 1.0 s | 91 | 0.973 | 0.455 | 0.476 | 0.610 |
| 3 | 1.3 s | 60 | 0.940 | 0.454 | 0.474 | 0.474 |
| 5 | 2.0 s | 36 | 0.878 | 0.454 | 0.472 | 0.354 |
| 10 | 3.6 s | 18 | 0.765 | 0.454 | 0.468 | 0.248 |
| 15 (present) | 5.2 s | 12 | 0.702 | 0.451 | 0.458 | 0.205 |
| 30 | 10 s | 6 | 0.628 | 0.446 | 0.452 | 0.157 |
| 60 | 20 s | 3 | 0.554 | 0.433 | 0.437 | 0.126 |

- The cap rises with fewer snapshots and is exactly 1 for one snapshot. This is by construction: the cap is the largest eigenvalue of a matrix of rank K at most, and white noise alone reaches 0.61 with two snapshots.
- The fit does not rise: the Bartlett value of a replica is the mean of its values for the single snapshots, however they are grouped. On the fixed track it is 0.451 with 15 snapshots and 0.455 with one. The motion of the source within 5 s therefore costs 0.004.
- Refitting range and depth in each window gains 0.02 with one snapshot; this includes fitting the noise of 182 windows with two free values each.
- So fewer snapshots widen the gap between fit and cap and make the cap useless as a reference. The mismatch is in every single snapshot (0.455), in line with Section 9 (the residual is nearly the same in adjacent snapshots).
- For the inversion, shorter windows would not add information. If each window keeps its weight in the likelihood, more windows of fewer snapshots would count the same correlated data more often and narrow the posterior without reason (Section 9).
- Windows of 15 snapshots are kept.

## 20. Is the range-dependent profile the most promising way to raise the fit? Assessment (2026-11-15)

Question of Florian Meyer. Assessment from the tests of Sections 12 to 19; no new test, no code changed. It replaces the recommendation of Section 14.4, which rested in part on the two rows of the synthetic test that were withdrawn (Section 14.3).

**Answer: no.** Expected gain of the range-dependent run of Section 16: about 0.01 in the mean Bartlett value.

- Direct test on the data (Section 16.6, local search): EOF coefficients at the array raise the held-out value from 0.448 to 0.458; the differences between source and array add nothing (0.458).
- The model can only hold small differences (Section 16.3: 0.25, 0.5, and 1 standard deviation, the limit of the adiabatic pairing). In the synthetic test, differences of this size leave a match of 0.78 to 0.89 where the data have 0.64 (Section 14.3). Even if the hypothesis is right, the part that this model can represent does not account for the gap.
- Exchanging the cast (Section 12.1): no cast gives more than 0.485; XBT 10, launched on the path at the time of the 20:30 file, is not better than XBT 11.
- The other project (Section 12): the comparable steps gained 0.02 (EOFs) and 0.01 or less (adiabatic range dependence).

**What the tests say about the mismatch**

- It is in every single snapshot (0.455 with one snapshot, Section 19), about equal at all tones, not smooth over the array, and not tied to a hydrophone (Section 14.1). So it is not averaging, tilt, a curved array, or a channel.
- It grows with range: 0.45 at 1 km, 0.24 at 1.7 km, 0.19 to 0.20 at 2.4 to 3 km, while the cap stays at 0.69 to 0.72 (Section 18.3).
- The gain of the inversion over the MFP environment belongs to the path of the 21:00 file: it does not carry over to the 20:30 file at the same range on the other side of the array (Section 18.3).
- All variants of the present model family end between 0.45 and 0.48 (single window 0.482 on its own window, joint 0.455, with EOFs 0.46).
- My reading: the mismatch comes from propagation that a smooth, deterministic, adiabatic model does not represent (fine structure of the water column with mode coupling, scattering). This is consistent with the hypothesis of a range-dependent water column, but the planned model is too limited to capture it. Not proven.

**Suggested order**

1. Fit each tone alone (local search, minutes). At 503 Hz the MFP reference state fits better than the joint MAP (0.521 against 0.493), so the tones pull apart. If single tones reach their caps, the error depends on frequency and a model change can help; if not, the limit is in the spatial structure of each tone.
2. Finish the test of the water depth difference (Section 17.3) and try the height of the array above the seafloor as an unknown (fixed at 7.25 m at present; no extra KRAKEN run). Minutes each.
3. Run only the control of Section 16 (EOF coefficients, same profile at both ends, about 13 h). Purpose: estimates that do not absorb the profile error, not a higher fit. In the local search the seabed moved strongly with the EOFs free (speed at the seafloor 1549 to 1487 m/s, thickness 3.5 to 1.7 m).
4. Joint inversion of the 20:30 and 21:00 files with a common seabed and array (noted as preferable in `NOTES.md`). It will not raise the fit; it gives a seabed that holds on two paths.
5. Range dependence beyond the adiabatic limit needs coupled modes or a parabolic equation. Whether that is worth it depends on the temperature loggers.

## 21. 3-D propagation: horizontal refraction by the bottom slope (2026-11-15)

Question of Florian Meyer. Estimate with the modes of the joint MAP (Section 13.6); scratch script, no code changed.

Method (adiabatic modes, horizontal rays, small deflection): the slope across the path is 0.0149 (slope 0.0152 of Section 17.2, path 12 deg off the isobaths). The wavenumber of mode m changes across the path as k_m (1 + g_m y) with g_m = slope * (dk_m/dD) / k_m; dk_m/dD from two KRAKEN runs with water depths 0.5 m apart. The path of mode m between two points bows upslope; its phase is k_m (L - g_m^2 L^3 / 24) instead of k_m L, its total turning angle g_m L, and its largest offset from the straight line g_m L^2 / 8. The field with these phase changes is compared with the field without them (16 hydrophones, source at the MAP depth).

| range | largest turning angle | largest offset of a mode path | largest phase change of a mode, 503 to 1253 Hz | squared correlation with and without, lowest tone value |
|---|---|---|---|---|
| 1.0 km (20:30, 21:00) | 0.4 deg | 1.0 m | 0.3 to 0.7 deg | 1.000 |
| 1.7 km (21:10) | 0.7 deg | 2.8 m | 1.6 to 3.4 deg | 1.000 |
| 2.4 km (21:20) | 1.1 deg | 5.5 m | 4.6 to 9.6 deg | 0.999 |
| 3.0 km (21:30) | 1.3 deg | 8.6 m | 9 to 19 deg | 0.997 |
| 5.0 km (19:30) | 2.2 deg | 24 m | 42 to 87 deg | 0.980 |

- The largest values belong to the steepest trapped modes (grazing angle at the seafloor about 18.6 deg, g_m = 0.008 per km). These modes carry little of the field, so the field changes far less than their phase.
- Horizontal refraction by the slope is negligible at all ranges of the data: no change at 1 km, 2% at most at 5 km. It grows with the cube of the range. It does not explain the mismatch (rms phase error 43 to 55 deg at 1 km, Section 14.1) or the loss of fit with range (Section 18.3).
- What the slope does change is in the plane of propagation: the array is about 200 m upslope of the tow track, so the source end is about 3.6 m deeper (Section 17). This is a 2-D effect and is covered by a water depth difference with adiabatic modes.
- Not covered by this estimate: horizontal refraction by the water column (fronts, internal waves; the path runs along the isobaths and therefore roughly along the fronts of internal waves that travel across the slope), and bathymetric features smaller than the grid spacing of about 100 m.

## 22. Measurements that exist but are not in `Matlab/Data` (2026-11-15)

Update of 2026-11-17: the experiment folder on the data server holds most of them, and they are now in `Matlab/Data` (Section 38.1). Only the compass and tilt sensors of the arrays are still missing.

Florian Meyer asked about the logger data mentioned in Section 15. Sources: `Matlab/Data/ReadMe_SBCEXP22.txt` and the trip report `Reports/SBCEXP22-LegC-Trip-Report.pdf` (Sec. 3, Table 2, Figs. 10 and B.3.3, App. B.3). `Matlab/Data` holds only `acoustic`, `ancillaryData/CTDs`, `ancillaryData/XBTs`, and `processed/AIS`, `processed/CTDs`, `processed/XBTs`.

| measurement | what the sources say | where in the data set | use for the inversion |
|---|---|---|---|
| Temperature loggers on the VLA (TLoggers, Onset HOBO U12-015) | 16 on each array, 0.23 m below each hydrophone (-0.23 m to 56.02 m relative to hydrophone 1), one more on the marker float (62.05 m). VLA1 at the shelf break: JD 147 1250Z to JD 150 1250Z, about 135 to 198 m depth (Fig. 10) | `processed/TLoggers_HOBO` (plots and matfiles); unprocessed files in `ancillaryData` | sound speed at the hydrophones at the time of the data; variability over minutes and hours |
| Tilt, heading, depth, and temperature sensors on the VLA (Star-Oddi Starmon Compass) | three on each array, near the bottom, middle, and top hydrophone (-0.5 m, 29.5 m, 55.75 m relative to hydrophone 1) | not named in the readme; CTD 28 was a calibration cast for the TLoggers and these sensors | measured tilt (with direction) and depth of the array: tilt and hydrophone depths would no longer be unknown or tied to the water depth |
| Source depth during the tows | plots and matfiles | `processed/sourceDepth` | check of the estimated source depth (124.0 m, std 0.4 m; nominal 120 m), or fix it |
| Ship GPS | matfiles, two versions | `processed/shipPositions` | source track; at present the track is a straight line between the positions of three XBT launches one hour apart |
| Bathymetry | 25-m grid of the deep-water site; multibeam and echo sounder of the ship on request | `processed/HighRes_Bathy`; cruise data | water depth along the path (Section 17) |
| Wind | plots and matfiles | `processed/windSpeed` | sea state |
| OOI Pioneer moorings near the site | Table 2 of the trip report: PMCO at 40.0968 N, 70.8792 W (about 5.4 km north of VLA1); OSSM, OSPM, PMUO near 39.94 N | not part of the data set (public OOI data, as far as I know) | profiles of the whole water column near the site at the time |

- This settles the open question of Section 15: the loggers were on the VLA itself. They cover the lower 60 m of the water column (the depths of the hydrophones); the source at 124 m is just above the highest logger, and the upper water column (sound speed minimum near 40 m) is not covered.
- Fig. 10 of the trip report shows temperatures between about 12 and 14.5 deg C at the array that change within hours (1 deg C is about 3 to 3.5 m/s). The casts cannot show this.
- The tilt, heading, and depth sensors and the measured source depth had not been noted before in this file. They are the most direct way to remove unknowns from the inversion and to check its estimates.

## 23. Range-dependent inversion started on the server (2026-11-15)

Florian Meyer asked to start the inversion of Section 16 with adiabatic modes (profile of the water with EOF coefficients at the array and differences at the source, 13 unknowns, 20,000 samples). The control run (same profile at both ends) is not started.

- Before the start: the server had no job of this account running (load 1.6). All casts for the EOFs (CTD 15, 16, 18, 20, 21 and XBT 9 to 21), the 21:00 file, and the Linux KRAKEN were already in the clone.
- Code: the seven files of Section 16.5 were copied to `/var/tmp/<user>/GI-SBCEX22/Matlab/Work-in-Progress/GI`; checksums equal to the local files. The four files that were replaced are kept in `/var/tmp/<user>/backup-20261115T1432`. The clone is still at commit `f0957d7` plus these uncommitted files.
- Start: 2026-11-15, 14:33 PST, with the command of Section 16.5. Process 247626 (`/var/tmp/<user>/inversionEOFRangeDependent.pid`), log `/var/tmp/<user>/inversionEOFRangeDependentLog.txt`, run folder `/var/tmp/<user>/runs/eofRangeDependent`.
- **The result files are written into the run folder**, not into the `GI` folder of the clone: `resultsDataEOFRangeDependentTmp.mat` after 10,000 samples and `resultsDataEOFRangeDependent.mat` at the end.
- Check at 14:38 PST: pool of 10 workers; the initialization of the proposal covariances (`getCovariancesSampling.m`, now `parfor`, first run with a real pool) runs for all ten temperatures at once, 165 to 317 steps each after about four minutes; no errors or warnings in the log; each temperature has its own KRAKEN files in the run folder (`SBCEXP22Compute1` to `10`). Starting from a separate run folder works.
- Expected (estimates): initialization a few hours, then about 650 samples per hour; intermediate file on 2026-11-16 in the morning, end around midnight from 2026-11-16 to 2026-11-17 (PST).
- When it has ended: download `resultsDataEOFRangeDependent.mat` from the run folder (local name with the start time, `resultsDataEOFRangeDependent_run20261115T1433_20000samples.mat`), run `showResultsData.m` (profiles at both ends, check of the adiabatic modes) and `checkHeldOutWindows.m` (held-out frames), and compare with the joint run (Section 13.6: held-out frames 0.448, fitted frames 0.455) and with the local search of Section 16.6 (0.458). Look at whether the differences sit at their prior bounds (Section 16.3).
- Another job of the same account (another project) appeared on the server during the check. It was not touched.

## 24. Could a missing hard layer in the seabed cause the low fit? (2026-11-15)

Question of Florian Meyer. Short test on the 21:00 file (scratch script, not in the repository; no code changed).

What the earlier runs say:

- A hard halfspace within 5 m of the seafloor was allowed by the prior (halfspace speed 1550 to 1900 m/s, thickness 0.5 to 5 m) and is rejected by the data: 1588 m/s, std 4 m/s (Section 13.6). In the sensitivity test of Section 12.1, halfspace speeds of 1650 and 1750 m/s lowered the fit from 0.483 to 0.438 and 0.353.
- Not covered by the runs: a hard layer deeper than 5 m. Hints that the seabed is harder at depth than the model allows: the thickness leans against its bound of 5 m; at 503 Hz the MFP environment (halfspace 1650 m/s) fits better than the joint MAP (0.521 against 0.493); the 20:30 file prefers the MFP environment (Section 18.3).

Test: seabed of the joint MAP (gradient layer of 3.84 m from 1553.6 to 1588.0 m/s), then sediment with the values of the MAP halfspace (1588 m/s, 1.85 g/cm^3, 0.65 dB/(m kHz)) down to the depth of the hard layer, then a hard halfspace (density 2.1 g/cm^3, attenuation 0.65 dB/(m kHz)). KRAKEN with three media and modes up to the speed of the hard halfspace, so the steeper modes that it traps are included (75 to 92 modes instead of 44 at 503 Hz). All 12 frames; "refit": range, source depth, tilt, and water depth fitted again on the six fitted frames (`fminsearch`); the seabed is not fitted again.

| hard halfspace | depth below the seafloor | squared correlation with the field of the present model, 503 / 1253 Hz | Bartlett, state fixed: fitted / held-out frames | after the refit: fitted / held-out frames |
|---|---|---|---|---|
| none (present model) | | | 0.455 / 0.448 | |
| 1800 m/s | 3.84 m | 0.879 / 0.954 | 0.408 / 0.404 | 0.421 / 0.400 |
| 1800 m/s | 5 m | 0.904 / 0.988 | 0.432 / 0.426 | 0.444 / 0.434 |
| 1800 m/s | 8 m | 0.975 / 0.999 | 0.441 / 0.437 | 0.451 / 0.444 |
| 1800 m/s | 12 m | 0.992 / 1.000 | 0.456 / 0.449 | 0.457 / 0.447 |
| 1800 m/s | 20 m | 0.994 / 1.000 | 0.454 / 0.449 | 0.454 / 0.447 |
| 1700 m/s | 5 m | 0.939 / 0.992 | 0.446 / 0.437 | 0.450 / 0.441 |
| 1700 m/s | 8 m | 0.986 / 0.999 | 0.441 / 0.437 | 0.448 / 0.441 |
| 1700 m/s | 12 m | 0.995 / 1.000 | 0.454 / 0.448 | 0.455 / 0.447 |
| 2000 m/s | 8 m | 0.952 / 0.997 | 0.445 / 0.436 | 0.449 / 0.437 |

- A hard layer at 12 m or deeper changes the field at the array by less than 1% at all tones and leaves the fit where it is. These data cannot see it, so its absence cannot be the reason for the low fit.
- A hard layer at 8 m or shallower changes the field, most at 503 Hz, and lowers the fit.
- No case raises the fit of the held-out frames above the present 0.448.
- Limits: sediment attenuation above the hard layer as assumed (0.65 dB/(m kHz)); with much less attenuation a deep layer would be seen better. Only the geometry was fitted again, not the seabed. Only the range of 1 km.
- Conclusion: no. The hints listed above point to a speed that keeps rising slowly with depth, which can be worth a few hundredths at 503 Hz, not the gap to the cap of 0.70.

## 25. What may be missing: roughness, and where in the field the mismatch sits (2026-11-15)

Question of Florian Meyer: what are we missing; has the roughness of the bottom been considered? It had only been named, not examined. Two diagnostics at the joint MAP on the 12 frames of the 21:00 file (scratch script, not in the repository; no code changed). A third test (25.3) was started afterwards.

Facts used: sound speed of XBT 11: 1497.0 m/s at the surface, minimum 1488.2 m/s at 31 m, 1506.2 m/s at the source depth, maximum below 100 m 1506.8 m/s, 1502.9 m/s at the seafloor. The surface is slower than the water at the source, so all energy that leaves the source upwards reaches the surface. Wind during the tow: 8 to 9 m/s from the south (trip report, Fig. 5), so an rms wave height of a few decimetres is plausible (my estimate).

### 25.1 Roughness as scattering loss

KRAKEN with an rms roughness of the sea surface and of the seafloor (SIGMA of the two interfaces; perturbation theory, the roughness adds attenuation to the modes that touch the interface). Checked: surface roughness changes only the modes that reach the surface, seafloor roughness only the modes that reach the seafloor. State fixed at the MAP; mean Bartlett value of the fitted / held-out frames:

| surface \ seafloor | 0 m | 0.1 m | 0.3 m | 0.6 m | 1.0 m |
|---|---|---|---|---|---|
| 0 m | 0.455 / 0.448 | 0.455 / 0.448 | 0.453 / 0.449 | 0.442 / 0.445 | 0.406 / 0.419 |
| 0.2 m | 0.454 / 0.449 | 0.453 / 0.449 | 0.451 / 0.449 | 0.439 / 0.443 | 0.403 / 0.416 |
| 0.35 m | 0.450 / 0.448 | 0.450 / 0.448 | 0.447 / 0.447 | 0.432 / 0.439 | 0.397 / 0.411 |
| 0.5 m | 0.442 / 0.444 | 0.442 / 0.443 | 0.437 / 0.441 | 0.422 / 0.431 | 0.388 / 0.403 |
| 0.8 m | 0.411 / 0.420 | 0.411 / 0.420 | 0.406 / 0.417 | 0.393 / 0.406 | 0.366 / 0.383 |

- No roughness raises the fit; the best value is no roughness, also after a refit of the geometry. Plausible values (surface up to 0.35 m, seafloor up to 0.3 m) change the fit by 0.005 or less; larger values lower it.
- The added attenuation is small at this range: 0.6 dB/km on average at 803 Hz for a surface roughness of 0.35 m, 0.3 dB/km for a seafloor roughness of 0.3 m. The energy that roughness removes from the coherent field within 1 km is therefore a few percent, far less than the unexplained part.
- Not covered: the scattered field itself (it is not modelled, only its loss), and seafloor relief on scales of tens to hundreds of metres, which is bathymetry that changes along the path (Section 17).

### 25.2 Which part of the field is modelled badly

The modes were split into six groups by their grazing angle at the seafloor (modes that turn above the seafloor; 0 to 5, 5 to 9, 9 to 13, 13 to 16, 16 to 19 deg). In ray terms the groups are the arrival families (direct, bottom, surface, ...). For each frame and tone, one complex gain per group was fitted to the largest eigenvector of the data (model: all gains equal).

- Share of the model field power: 15 to 22% (0 to 5 deg), 46 to 51% (5 to 9 deg), 2 to 7% (9 to 13 deg), 18 to 24% (13 to 16 deg), 3 to 10% (16 to 19 deg); the modes that turn above the seafloor carry nothing at the source and the array.
- Phases of the groups relative to the strongest group (5 to 9 deg), mean over the 12 frames: 0 to 5 deg: -9 to -14 deg at all tones; 13 to 16 deg: -11 to +3 deg; 16 to 19 deg: -13 to +3 deg (503 to 1003 Hz). They are the same in all frames (consistency 0.83 to 1.00). The small group 9 to 13 deg and the steepest group at 1253 Hz scatter.
- Amplitudes relative to the strongest group: 1.0 to 1.5 for the steep groups at 503 to 1003 Hz, 0.8 at 1253 Hz. The steep groups do not lack energy; roughness or any other extra loss of the steep modes would show as amplitudes below 1.
- Fit: model 0.455 / 0.448 (fitted / held-out frames); gains fitted in every frame (6 complex values per tone and frame, fits noise too): 0.539 / 0.537; gains taken from the fitted frames and held fixed: 0.475 / 0.453. Control with random groups of modes: 0.446 on the held-out frames.
- **Result: the arrival families have the right relative phases (within about 15 deg) and amplitudes; correcting them gains 0.005. The mismatch is inside the families**, i.e. in the shape of each arrival across the 56-m aperture (arrival angles, turning points) and in the relative phases of neighbouring modes. Errors that act smoothly in grazing angle are therefore unlikely as the main cause: a wrong mean water depth or bathymetry along the path, extra loss at the surface or the seafloor, seabed reflection phase.
- What does act inside the families: the sound speed at the depths of the array and the source. Both sit at the weak sound speed maximum of the lower water column (1506.2 m/s at the source, 1506.8 m/s maximum, 1502.9 m/s at the seafloor). The modes with small grazing angles turn inside or just above the aperture, and 1 m/s changes their turning depths and arrival angles (a change of 1 m/s turns a 6-deg arrival by about 0.4 deg, which is 1 rad across the aperture at 503 Hz). The loggers on the array show changes of 1 to 1.5 deg C (3.5 to 5 m/s) within hours at these depths (Section 22). The three EOFs of the casts are dominated by the upper 80 m.
- This agrees with the feeling of Florian Meyer that a water column effect (internal waves, the moving boundary of the warm layer) is missing, and it is local in depth: the lower 80 m. It need not depend on range.

### 25.3 Test: free sound speed in the lower water column

Local search on the six fitted frames from the joint MAP (`fminsearch`, as in Section 16.6; not an inversion result). XBT 11 gets a free change at five depths, linear in between: in the lower layer at 110, 130, 150, 170, and 190 m (zero at 90 m and above), and as a control with the same number of free values in the upper layer at 10, 30, 50, 70, and 90 m (zero at 110 m and below). Bounds of the changes: 6 m/s.

| free | fitted frames, logL | fitted frames, Bartlett | held-out frames, logL per frame | held-out frames, Bartlett |
|---|---|---|---|---|
| joint MAP | 296.5 | 0.455 | 48.7 | 0.448 |
| geometry fitted again (control) | 296.6 | 0.455 | 48.6 | 0.448 |
| lower layer and geometry | 311.6 | 0.473 | 51.3 | 0.466 |
| lower layer, geometry, and seabed | 313.4 | 0.475 | 51.4 | 0.467 |
| upper layer and geometry | 297.4 | 0.456 | 48.6 | 0.448 |
| upper layer, geometry, and seabed | 297.8 | 0.456 | 48.8 | 0.449 |

- The lower layer gains 0.019 on the held-out frames, the upper layer nothing. This is the largest gain of any change tried so far (three EOF coefficients: 0.010, Section 16.6), and it is in the layer where Section 25.2 puts the sensitivity.
- It is far from closing the gap: 0.467 against a cap of 0.70. A smooth change of the lower layer, constant over the path and the file, is therefore not the whole missing piece.
- Fitted change: +2.8, +1.8, +1.0, +3.4, +2.4 m/s at 110, 130, 150, 170, 190 m, i.e. faster than XBT 11 throughout the lower layer, most below 160 m. With it, the source depth moves from 124.0 to 119.6 m (nominal tow depth 120 m), the range from 1013 to 988 m (GPS range 1030 m), the tilt from 0.13 to -0.09 deg, and the seabed changes little (1548 m/s at the seafloor, 1596 m/s halfspace). These values are from a local search and show how strongly the geometry trades off with the profile; they are not estimates.
- Per tone on the held-out frames: 0.543, 0.478, 0.456, 0.433, 0.425 (joint MAP: 0.528, 0.453, 0.448, 0.423, 0.390).
- Open after this test: structure finer than 20 m in the lower layer, changes in time and along the path, and the depths of the hydrophones relative to the seafloor (Section 20, step 2; not tested). The loggers and the depth sensors on the array measure the first and the last of these (Section 22).

## 26. Range-dependent run: status on 2026-11-15 at 23:26 PST

- Running since 14:33 PST (Section 23), no errors or warnings in the log. Sample 3,378 of 20,000; about 620 samples per hour (measured over half a minute), so the initialization took about 3.5 h. At this speed the intermediate file comes on 2026-11-16 around 10:00 PST and the run ends on 2026-11-17 around 02:00 PST.
- **The chain at temperature 1 is not in the main mode.** Its log-likelihood has been at about 200 since the first 250 samples (mean of each block of 250 samples 199.5 to 200.4, highest value 206.3), and no chain at any temperature has exceeded 206.3. The joint MAP of Section 13.6 with all EOF coefficients at zero is a state of this model and has a log-likelihood of 296.5 on the same six fitted frames (Section 16.4: with zero coefficients the model is identical to the joint model); the local search of Section 16.6 reached 305.
- State of the chain at temperature 1 at sample 3,378: range 1045.9 m (joint MAP 1012.8 m), source depth 122.9 m, tilt 0.07 deg, water depth 203.0 m (199.9 m), speed at the seafloor 1535.5 m/s, thickness 3.2 m, halfspace speed 1585.4 m/s, EOF coefficients at the array 0.86, 1.78, 1.15, differences 0.01, -0.30, -0.10. This is a secondary mode about 33 m further out in range.
- As long as no chain finds the main mode, the samples of this run do not describe the posterior. The chain has shown no movement towards it in 3,100 samples.
- Proposed: stop the run and start it again with the joint MAP and zero EOF coefficients as the first sample, so that the initialization and the sampling start in the main mode. Florian Meyer agreed; see Section 27.

## 27. Range-dependent run stopped and started again from the joint MAP (2026-11-15, 23:31 PST)

**Stopped run** (started 14:33 PST, Section 23): stopped at 23:31 PST at sample 3,430. Its initialization had taken 3 h 14 min (until 17:47 PST), and it sampled at about 600 samples per hour. It wrote no result file (the first one is written after 10,000 samples); its samples are from the secondary mode and are not kept. Its log is kept on the server as `/var/tmp/<user>/inversionEOFRangeDependentLog_run20261115T1433_stopped.txt`.

**Code**

- `mainData14L1HRangeDependent.m`: new settings `startResultsFile` and `startBurnIn`. With the name of a results file in the `GI` folder, the first sample of the initialization and of all chains is the MAP estimate of that run, with all EOF coefficients at zero (`scenario.firstSample`). With `''` the run starts at the centre of the prior as before. The setting is `resultsDataJoint_run20261114T1102_30000samples`.
- `scenario.priorMean` is unchanged: it is also the centre of the Gaussian prior of the source range in `evaluateLogPrior.m` (GPS range, standard deviation 100 m) and must not be moved to the start value.
- `getCovariancesSampling.m`: starts at `scenario.firstSample` if this field exists, otherwise at the prior mean as before. The other scripts do not set the field and are unaffected.
- Check on the MacBook (script up to the first sample, without the pool): the first sample has a log-likelihood of 296.49, the same as the joint MAP in the joint run; it is inside the prior, satisfies the coupling, and has the known values. The centre of the prior, where the stopped run started, has 75.35.

**New run**

- On the server: the two files were copied (checksums equal to the local files; the replaced versions are in `/var/tmp/<user>/backup-20261115T2331`), and the results file of the joint run was copied in the `GI` folder of the clone to the name used on the MacBook, `resultsDataJoint_run20261114T1102_30000samples.mat` (same checksum).
- Start: 2026-11-15, 23:31 PST, same command, run folder, and log name as in Section 23; process 351924.
- Check at 23:39 PST: pool of 10 workers, no errors or warnings; the initialization starts at the joint MAP, and the chain at temperature 1 is in the main mode (range 1013.3 m, source depth 124.0 m, water depth 199.9 m). After 8 minutes it has 2 to 3 of the 65 acceptances per unknown that it needs, the hotter chains 4 to 9.
- Expected (estimates): initialization about 3 to 3.5 h, until about 03:00 PST on 2026-11-16; intermediate file with 10,000 samples about 19:30 PST on 2026-11-16; end about noon on 2026-11-17.
- **To check when the sampling has started (after about 03:00 PST on 2026-11-16):** the log-likelihood of the chain at temperature 1 in the log should be near 296 or above, not near 200.
- When the run has ended: as listed in Section 23; the local name of the result file then carries the start time `20261115T2331`.

## 28. Range-dependent run: status on 2026-11-16 at 14:45 PST

- Running since 2026-11-15, 23:31 PST (Section 27), no errors or warnings in the log. Sample 5,952 of 20,000. There is no result file yet (the first one is written after 10,000 samples). All numbers below are read from the log (state of the chain at temperature 1 before the swaps, samples 2,001 to 5,952) and are preliminary.
- Speed: about 390 samples per hour (21 samples in 201 s). Since 08:12 PST a second job of this account with 22 MATLAB processes runs on the server (load 29 on 32 cores; it belongs to the other project and was not touched). Before that the speed was about 600 samples per hour. At the present speed the intermediate file comes about 01:00 PST on 2026-11-17 and the run ends about 02:00 PST on 2026-11-18; sooner if the other job ends.
- **The restart worked.** Log-likelihood of the chain at temperature 1: mean 301 (means of blocks of 500 samples 300.2 to 301.6, already in the first block), highest value 308.3 (sample 2,284). Joint run (Section 13.6): 296.5 at the MAP, 292.8 in the mean of the posterior samples. The gain is about 12 at the best sample and 8 in the mean, with 6 more unknowns. In terms of the mean correlation coefficient on the fitted frames this is about 0.455 to 0.47 (estimate from the log-likelihood, not computed from the fields; the local search of Section 16.6 had 0.465 at a log-likelihood of 305.0).

| parameter | mean (std), this run | mean (std), joint run |
|---|---|---|
| source range of frame 1 [m] | 1028.2 (13.9) | 1013.5 (6.7) |
| source depth [m] | 124.76 (1.34) | 124.00 (0.37) |
| tilt [deg] | 0.152 (0.066) | 0.142 (0.037) |
| water depth [m] | 202.16 (1.70) | 199.97 (0.58) |
| speedTop [m/s] | 1517.6 (28.9) | 1551.8 (9.3) |
| thickness [m] | 2.54 (1.21) | 3.80 (0.81) |
| speedH [m/s] | 1586.4 (8.6) | 1588.3 (3.9) |
| sspArray1, 2, 3 | -0.32 (0.35), 1.11 (0.83), 1.31 (0.47) | fixed at 0 |
| sspDifference1, 2, 3 | -0.00 (0.12), -0.05 (0.28), -0.23 (0.47) | fixed at 0 |

- **Profile at the array:** the data move the profile away from XBT 11 along EOF 2 and EOF 3 by more than one standard deviation of the casts. With the rms of one standard deviation of each EOF (2.16, 0.88, 0.73 m/s, Section 16.1) the three coefficients change the profile by about 0.7, 1.0, 1.0 m/s rms. Coefficients 2 and 3 are above 1.8 in 19% and 17% of the samples (prior bound 2).
- **Differences between the ends:** a uniform prior on the intervals of the differences has the standard deviations 0.14, 0.29, 0.58; the posterior has 0.12, 0.28, 0.47. The data do not resolve a difference between the source end and the array end inside these bounds; only the third coefficient leans to negative values. So far the gain comes from the profile that is common to both ends, not from the range dependence. The control run (Section 16.5) would measure this directly; it has not been started.
- **Geometry and seabed are less well determined than in the joint run** (standard deviations two to three times larger): the narrow posterior of the joint run was conditional on XBT 11 being the true profile. Range and water depth move together (correlation 0.95). The mean range is now 2 m from the GPS range (1030 m) instead of 17 m, and the mean water depth is close to the 201.7 m of the bathymetry grid at the array (Section 17); 5.4% of the samples have a water depth above 204.5 m (prior bound 205 m).
- Seabed: the speed at the seafloor ranges from 1450 to 1570 m/s and trades off with the thickness (mean thickness 1.2 to 1.5 m for speeds of 1460 to 1500 m/s, 3.9 m for 1540 to 1560 m/s). In 31% of the samples it is below 1500 m/s, i.e. below the sound speed of the water at the seafloor (1502.9 m/s). The thickness is above 4.5 m in 8.2% of the samples (joint run 23.7%). The halfspace speed is unchanged.
- Next, unchanged: when the intermediate file is there, evaluate it with `showResultsData.m` and `checkHeldOutWindows.m`. The held-out frames decide whether the gain is real; the comparison values are 0.448 (joint MAP), 0.458 (local search with this model, Section 16.6), and 0.467 (local search with free nodes in the lower water column, Section 25.3).
- The picture agrees with the local search of Section 16.6 (log-likelihood 305.0 and 0.465 on the fitted frames, third coefficient at the array large, third difference negative, seabed with a slow thin layer, differences adding little).

## 29. ORCA instead of KRAKEN: run time of the two ORCA builds (2026-11-16)

Question of Florian Meyer before ORCA is added as a second option to the inversion code: which of the two ORCA MEX builds of the other project is faster, the one that runs inside MATLAB ("in-process", two files) or the "guarded" one (the MEX file passes each call to a helper program and can stop a call that does not return; three files)? No code of the repository was changed. ORCA is not part of the repository and must not be committed (its license is unclear); the test used copies in a scratch folder on the server.

**Test.** On the server (the builds exist for Linux and Intel macOS only, so they cannot be loaded on the MacBook), MATLAB R2022a with one thread and low priority, while the range-dependent run (Section 28) and the job of the other project were running (load about 28 on 32 threads). The absolute times are therefore longer than on an idle server; the two builds were run at the same time, so their comparison is fair. Environment of the joint inversion (Section 13.6): 100 states (the MAP, 80 posterior samples, 19 samples of the hottest chain), five tones, mode shapes at the 16 hydrophone depths and the source depth, phase speeds up to the halfspace speed as in the KRAKEN run. Reference: `getModesSBCEXP22.m` (write the file, run KRAKEN, read the modes). Scratch script `orcaTimingTest.m` and logs in `/var/tmp/<user>/orcaTest` on the server.

Median time per state (all five tones):

| configuration | in-process | guarded |
|---|---|---|
| water profile with 201 points, all tones in one call | 1.69 s (1.68 s in a separate session) | 1.70 s |
| the same, one call per tone | 1.73 s | 1.72 s |
| water profile with 51 points | 0.31 s | 0.29 s |
| 201 points, layers merged by ORCA (`ctol` = 0.1 m/s) | 0.35 s | 0.36 s |
| 201 points, modes on a 1 m grid and interpolated | 1.92 s | not run |
| 500 points (the profile of the KRAKEN run) | 4.19 s | not run |
| 201 points, phase speeds up to 1800 m/s (leaky modes) | 2.03 s | not run |
| KRAKEN, 500 points | 0.22 s | |

- **The two builds are equally fast** (differences of 1 to 5% in both directions) and return identical results. The choice can be made on other grounds; the guarded build protects a long parallel run from a call that hangs.
- **ORCA is slower than KRAKEN here.** Its time grows in proportion to the number of points of the water profile: 8 times slower than KRAKEN with 201 points, 19 times with 500 points, about 1.4 times with 51 points. With ORCA the profile has to be thinned (fewer points, or `ctol`).
- Mode shapes only at the hydrophone and source depths (a list of depths is passed to ORCA): 12% faster than a 1 m grid with interpolation. One call for all tones or one call per tone makes no difference.
- No failed call and no partial result in any configuration.
- **ORCA and KRAKEN do not give the same field.** At the joint MAP, with the same phase speed limit, the correlation of the two fields is 0.95 to 0.98 per tone (0.91 at 803 Hz in the configurations where ORCA finds 69 instead of 70 modes). The cause was not examined (candidates: KRAKEN computes the attenuation of the modes by perturbation, ORCA solves for complex modes; modes close to cutoff).
- **Leaky modes change the field at this range.** With phase speeds up to 1800 m/s ORCA returns 74 to 185 modes per tone instead of 44 to 110, and the field has a correlation of only 0.70 to 0.83 with the KRAKEN field at the MAP. The present KRAKEN setup stops at the halfspace speed, i.e. at the critical angle. Whether the field with leaky modes is closer to the data has not been tested.
- Units: ORCA takes a positive attenuation as dB/(m kHz) and a negative one as dB/wavelength (`svp_check.f` of its source). The inversion uses dB/(m kHz), so the values are passed with a positive sign.
- The test left no process on the server; the range-dependent run was at sample 6,197 at 15:22 PST.

## 30. ORCA as a second propagation model (2026-11-16)

Request of Florian Meyer: a second option for the inversion code in which ORCA replaces KRAKEN, with the guarded ORCA build (Section 29) and all ORCA files in a folder that is not in Git.

**ORCA files (not in the repository)**

- `.gitignore`: new entry `Matlab/Orca/`. ORCA must not be committed or published (no clear license for redistribution).
- `Matlab/Orca/glnxa64` (Linux) and `Matlab/Orca/maci64` (Intel macOS): in each folder the MEX file `sub_orca.<mexext>`, the helper program `orca_helper`, and the wrapper `ORCA_MEX.m` of the guarded build of the other project (up to 200 modes per frequency). The folder names are `computer('arch')`, as for the KRAKEN binaries in `ReferenceCode/bin`. The three files have to stay together and `orca_helper` has to be executable. `Matlab/Orca/README.md` (local only) lists the origin and the checksums.
- **There is no build for Apple silicon**, so the ORCA option does not run on Florian Meyer's MacBook, and results of an ORCA run cannot be evaluated there with `showResultsData.m` or `checkHeldOutWindows.m` (they compute fields with the model stored in the results). The other project has a build script for Apple silicon; it has not been used here.
- Whoever takes over gets the folder `Matlab/Orca` from Florian Meyer.

**Code**

- `getModesOrcaSBCEXP22.m` (new): the modes from ORCA in the form of `getModesSBCEXP22.m` (mode shapes at the hydrophone depths and at the source depth, wavenumbers). One call for all tones; the depths are passed as a list, so nothing is interpolated; no files are written. Same environment as the KRAKEN file: water profile, sediment layer with gradients of speed, density, and attenuation, halfspace. Settings in `scenario.orca` (all optional, defaults in the function): `path`, `numSSPPoints` (65), `ctol` (0), `cphmax` (nan: speed of the halfspace, i.e. trapped modes only, as KRAKEN), `rmin` (0.5 km), `rmax` (5 km), `dbcut` (50), `phfac` (4), `maxModes` (200), and the limits of the guarded build `maxR1R2Evaluations` (250,000 per tone), `nativeTimeoutSeconds` (60), `nativeTerminateGraceSeconds` (2).
- `getModesSBCEXP22.m`: if `scenario.model` is `'Orca'`, it returns the modes of `getModesOrcaSBCEXP22.m`. Without the field, or with `'Kraken'`, nothing changes. All functions that call it (`getPressuresFromStateSBCEXP22.m` with the adiabatic branch, `getModePairingSBCEXP22.m`, `checkEffectiveSnapshots.m`) follow the setting, and so do the scripts that read `scenario` from a results file.
- `getNextSample.m`: a setup error of ORCA (`SBCEX:orcaUnavailable`: files missing, unknown setting) stops the run, as a missing KRAKEN binary does. A call that ORCA does not complete (`SBCEX:orcaFailed`: time or work limit, more than 200 modes, search stopped early) is a failed proposal: it is dropped and saved as an error sample, as a failed KRAKEN run is.
- `mainData14L1HJoint.m` and `mainData14L1HRangeDependent.m`: new settings `scenario.model = 'Kraken'` (unchanged behaviour), `scenario.orca.numSSPPoints = 65`, `scenario.orca.cphmax = nan`. With `'Orca'` the names of the result files end with `Orca`. In `mainData14L1HJoint.m` the name of the result file is now the variable `resultsFile`.
- Conventions (checked below): ORCA reads a positive attenuation as dB/(m kHz), the unit of the inversion. ORCA uses the opposite time convention to KRAKEN and to the modal sum in `getPressureSBCEXP22.m`; the function returns the complex conjugates of the wavenumbers **and of the mode shapes**. Conjugating only the wavenumbers is wrong in this environment (the mode shapes have imaginary parts of 10 to 30% of the real parts).

**Checks** (2026-11-16, on the server in a separate copy of the code, `/var/tmp/<user>/orcaTest/repo`; one MATLAB thread, server loaded as in Section 29; scratch script `orcaValidation.m` there). The clone of the running inversion was not touched.

- KRAKEN path unchanged: the joint MAP has 296.49 on the six fitted frames and 0.4547 / 0.4483 mean correlation on the fitted / held-out frames, as before.
- Against KRAKENC (complex modes, same phase speed limit) at the joint MAP: the ORCA field has a correlation of 0.9999 at four tones with trapped modes only, and of 0.9994 to 0.9999 with leaky modes up to 1800 m/s. At 803 Hz it is 0.92 to 0.94, where the two programs differ by one mode at the cutoff. KRAKENC was not timed. Without the conjugate of the mode shapes the correlation is 0.85 to 0.92 (trapped) and 0.70 to 0.89 (leaky).
- **KRAKEN (real modes, as used so far) differs from both**: correlation 0.90 to 0.97 with ORCA per tone at the MAP, 0.965 on average over 10 states. The forward model of the inversions so far therefore has an error of this size.
- Profile points (field against ORCA with 500 points; 10 states, 6 frames, 5 tones; time for one call, all tones):

| points, `ctol` | mean correlation | smallest | time |
|---|---|---|---|
| 51, 0 | 0.9988 | 0.9963 | 0.31 s |
| **65, 0 (default)** | 0.9993 | 0.9896 | 0.40 s |
| 101, 0 | 0.9998 | 0.9993 | 0.72 s |
| 201, 0 | 0.99998 | 0.9995 | 1.64 s |
| 201, 0.02 | 0.99998 | 0.9998 | 1.00 s |
| 201, 0.05 | 0.9999 | 0.9983 | 0.63 s |
| 201, 0.1 | 0.9994 | 0.9920 | 0.32 s |
| 201, 0.2 | 0.9961 | 0.9846 | 0.23 s |

  (Columns with the same number of modes as the reference. In 1 or 2 of the 10 states one mode at 803 Hz is at the cutoff and is counted by some settings and not by others; the correlation of those columns is about 0.93.) Default: 65 equally spaced points, the number the other project uses. Equally spaced points are preferred to `ctol` because the points then do not change with the profile.
- 100 states (MAP, posterior samples, hottest chain) with the defaults: no failure, 0.43 s per call (median; KRAKEN 0.22 s), at most 1,267 work units per tone (limit 250,000) and 0.6 s (limit 60 s).
- Range-dependent profile (EOF coefficients, adiabatic modes, two calls): runs with ORCA; 0.71 s against 0.54 s with KRAKEN.
- `getNextSample.m` with ORCA from the MAP: 18 of 28 proposals accepted (KRAKEN 17 of 28), no failed proposal.
- Failures: work limit, time limit, and too few rows for the modes give `SBCEX:orcaFailed`, and the next call works again; the sampler drops such a proposal and writes one error sample. An unknown setting, a folder without ORCA, and an unknown model stop the run.
- `checkcode` reports nothing for the new and edited functions.
- Not tested: a complete inversion with ORCA and the two main scripts with `scenario.model = 'Orca'` (they start an inversion; the changes there are the setting and the name of the result file).

**Findings for the use of ORCA**

- Fit of the joint MAP with ORCA (the state was estimated with KRAKEN and is not refitted):

| model | logL, fitted frames | correlation, fitted | correlation, held out |
|---|---|---|---|
| KRAKEN | 296.49 | 0.455 | 0.448 |
| ORCA, trapped modes (default) | 290.87 | 0.448 | 0.434 |
| ORCA, phase speeds up to 1650 m/s | 268.47 | 0.421 | 0.403 |
| ORCA, up to 1700 m/s | 268.37 | 0.421 | 0.403 |
| ORCA, up to 1800 m/s | 266.38 | 0.418 | 0.400 |

  At this state the leaky modes lower the fit; they do not explain the mismatch here. Whether another state fits better with them can only be said after an inversion with ORCA.
- One mode at 803 Hz is at the cutoff at the joint MAP: ORCA counts it with 65 points (70 modes, logL 290.87) and not with 101 or 500 points (69 modes, logL 284.87). The limit of the phase speed at exactly the halfspace speed makes the likelihood jump when a mode crosses it; this also holds for KRAKEN.
- **Limit of 200 modes:** with the default (trapped modes) ORCA fails at 1253 Hz for halfspace speeds of 1870 m/s and more (prior up to 1900 m/s), and with `cphmax` of 1900 m/s. Such proposals are dropped, so the hot chains cannot go above about 1870 m/s. The posterior is far from this value (1588 m/s).
- `rmin` has to be a real range: with `rmin` = 1000 km only 15 to 27 modes are returned.
- Speed: about twice the time of KRAKEN per proposal with the defaults.

## 31. Temperature loggers of VLA1 and ship data (2026-11-16)

Florian Meyer obtained the logger files and the ship data on 2026-11-16 and asked what they say about the mismatch. New in `Matlab/Data/ancillaryData` (not in Git): `Tlogger_HOBO_csv_files` (35 loggers, one sample per minute, 2022-05-22 to 2022-05-31) and `cruise_data_legC` (ship's underway log, echosounder, ADCP, XBT). The analysis was done with scratch scripts in MATLAB on the server (`/var/tmp/<user>/tlogger`); no code of the repository was changed.

### 31.1 Which logger was where

The files carry serial numbers only. From the temperatures: serial numbers 20475326 to 20475342 were on VLA1 and 20475343 to 20475359 on VLA2 (at the shelf break the first group has 12.7 to 14.1 deg C, the second 7.3 to 9.2 deg C); 20475360 was on neither array. Within an array the serial numbers run from the top (logger on the marker float) to the bottom (logger below hydrophone 1); this agrees with Fig. 10 of the trip report (warmest at the top). Heights above hydrophone 1 from the mooring diagram: 62.05 m (float), 56.02 m to 3.52 m in steps of 3.75 m, -0.23 m; with hydrophone 1 at 7.25 m above the seafloor the loggers are 7.0 to 69.3 m above the seafloor, i.e. the lowest third of the water column. VLA1 was on the seafloor from 13:00Z on JD 147.

Calibration with CTD #28 (JD 151, 2014Z to 2140Z, all loggers on the CTD frame; 24 Hz file, five stops of 5 to 7 minutes between 8.7 and 14.0 deg C): the loggers read 0.03 deg C high on average, with a standard deviation of 0.03 deg C between the loggers. The offset of each logger was removed. The loggers are good to about 0.05 deg C (0.15 m/s).

### 31.2 Water depth at VLA1

- **Echosounder.** The ship's 3.5 kHz echosounder was off during the tow and the deployment, but on JD 146 (19:15Z to 19:34Z and 20:02Z to 20:14Z) the ship passed twice over the site of VLA1 along the line of the later tow. Logged depth (to the surface, sound speed setting 1490 m/s) within 100 m of the position of VLA1: 202.3 and 202.6 m (first pass), 203.9 m (second pass). With the sound speed of the water (about 1499.5 m/s on average over the column, estimated from XBT #11) this is about 203.8 and 205.1 m. The positions in the minute log are rounded to 0.001 deg (about 100 m), which is about 1.5 m of depth across the slope.
- **Loggers against CTD #16** (0.5 km from VLA1, 13:12Z, i.e. when the array had just reached the seafloor): the logger temperatures fit the cast best if the loggers are 4.5 to 6 m deeper than for a water depth of 199.9 m (rms difference 0.22 deg C without a shift, 0.10 deg C with 6 m; the same for the loggers 30, 60, and 120 minutes later). This gives a water depth of about 204.4 to 205.9 m, if the heights of the mooring diagram hold. Fig. 10 of the trip report also places the loggers about 4 m deeper than a water depth of 199.9 m would.
- **The joint inversion has 199.9 m (standard deviation 0.6 m), 4 to 5 m less.** The prior is 195 to 205 m, so the measured depth is at its upper bound. The run with EOF coefficients (Section 28) has 202.2 m (1.7 m).
- Along the line of the tow the echosounder gives 1.4 to 2.1 m more water 1 km east of VLA1 (where the source was at 2100Z) than at VLA1 (the 3-arc-second grid of Section 17 has 3.6 m).

### 31.3 The water at the array at 2100Z against XBT #11

Loggers at 2100Z minus XBT #11 (launched 2132Z, 3.4 km east of VLA1), for the logger depths of a water depth of 199.9 m:

| depth | 131 to 152 m | 155 to 167 m | 170 to 186 m | 189 m | 193 m |
|---|---|---|---|---|---|
| temperature | -0.05 to +0.06 deg C | +0.14 to +0.21 | +0.41 to +0.64 | +0.18 | -0.05 |
| sound speed | -0.2 to +0.2 m/s | +0.5 to +0.7 | +1.4 to +2.1 | +0.6 | -0.2 |

- With the loggers deeper the difference is larger and covers more of the column. Water depth 202.8 m (Section 31.5): +1.3 to +2.4 m/s at 166 to 185 m and +1.4 m/s at 158 m, mean over the 17 loggers +0.94 m/s. Water depth 204.5 m (Section 31.2): +0.7 to +2.5 m/s from 156 to 194 m, mean +1.07 m/s.
- It is a difference in space, not in time: at 2132Z, when XBT #11 was launched, the loggers are still 0.6 to 0.7 deg C warmer than the XBT at 170 to 182 m.
- The test with free sound speed in the lower water column (Section 25.3) had pointed to this: it raised the profile by 3.4 m/s at 170 m. The loggers confirm a faster lower layer at the array. The run with EOF coefficients does not: its profile at the array is slower than XBT #11 below 110 m (Section 32). They do not confirm the 1.8 to 2.8 m/s that the test of Section 25.3 added at 110 to 130 m: the top logger (131 m) agrees with the XBT.
- XBT #10 (2032Z, 0.6 km from VLA1) is 0.15 to 0.45 deg C warmer than the loggers at the same time; XBT #9 and #12 and CTD #18 agree with the loggers to 0.2 deg C rms.

### 31.4 Changes in time at the array

- Between 1930Z and 2200Z the temperatures at fixed heights change little (standard deviation 0.02 to 0.18 deg C), except at the step between the water of 14.0 deg C and the water of 13.6 deg C (0.4 deg C, about 1.3 m/s).
- This step moves: its height above the seafloor (13.8 deg C isotherm) is 56 to 58 m from 1900Z to 2015Z, 50 m at 2030Z, 46 m at 2050Z, and about 42.5 m from 2059Z to 2103Z, its lowest point; by 2110Z it is back at 49 m, and at 2200Z it is at 44 m again. So the step went down by about 15 m in 45 minutes, was at its lowest point exactly during the frames of the 2100Z file, and came back up by 7 m within 7 minutes.
- Any single cast is a snapshot of a water column that changes within minutes. XBT #11 has its step at about the depth where the loggers have it at 2100Z, which may be why it fits this file best of all casts.

### 31.5 Acoustic test: the profile of the loggers in the forward model

Scratch scripts `tloggerStage3.m` to `tloggerStage5.m` on the server (logs `log_stage3_b.txt`, `log_stage4_1.txt` to `log_stage4_3.txt`, `log_stage5.txt` in `/var/tmp/<user>/tlogger`). Water profile: XBT #11 above the top logger; below, the sound speed from the logger temperatures at 2100Z (Mackenzie, salinity of CTD #16, as for the XBTs), interpolated between the loggers. The loggers move with the water depth, as the hydrophones do. No free parameter is added. Search for each profile: a grid over water depth (198 to 208 m), range (985 to 1060 m), and source depth (121, 124, 127 m), then local searches of all 7 unknowns from the three best grid points, on the six fitted frames; the held-out frames are evaluated afterwards. Prior of the water depth 195 to 210 m in this test.

| water profile | model | logL, fitted frames | correlation, fitted | correlation, held out | range | source depth | water depth |
|---|---|---|---|---|---|---|---|
| XBT #11 (as in the inversion) | KRAKEN | 296.5 | 0.455 | 0.447 | 1014.6 m | 124.0 m | 200.1 m |
| loggers below the top logger, same profile at both ends | KRAKEN | 312.7 | 0.473 | 0.464 | 1015.6 m | 121.8 m | 202.8 m |
| loggers at the array, source end 29% of the way to XBT #11 (adiabatic modes) | KRAKEN | 281.0 | 0.439 | 0.432 | 1012.5 m | 122.0 m | 202.4 m |
| XBT #11 | ORCA | 294.2 | 0.452 | 0.439 | 1013.2 m | 124.0 m | 199.9 m |
| loggers below the top logger | ORCA | 305.8 | 0.465 | 0.449 | 1019.5 m | 122.0 m | 203.0 m |

- **The measured profile raises the fit, without any new unknown:** +16 in the log-likelihood, 0.448 to 0.464 on the held-out frames, and all five tones improve (held out: 0.538, 0.471, 0.457, 0.436, 0.418 against 0.528, 0.453, 0.448, 0.423, 0.390). This is as much as the free nodes of Section 25.3 gave (0.467) and more than the EOF coefficients in the local search of Section 16.6 (0.458).
- **The geometry moves towards the independent measurements:** water depth 200.1 to 202.8 m (echosounder about 204 to 205 m), source depth 124.0 to 121.8 m (nominal tow depth 120 m), tilt 0.14 to -0.05 deg. The range stays about 15 m short of the GPS range (1030.4 m). The thickness goes to its upper bound (4.9 m).
- With XBT #11 the data do not allow the measured water depth: the best log-likelihood for 204.5 m is 243, against 296.5 at 200 m. With the logger profile it is 276 at 204.5 m against 296 on the grid at 201 m.
- **The gain is a small part of the gap** to the cap of 0.70. The lower third of the water column at the array is not the main cause of the mismatch.
- A source end that goes part of the way to XBT #11 lowers the fit below both consistent choices. The difference between VLA1 and the position of XBT #11 (3.4 km) is therefore not a trend that holds along the 1 km path.
- **ORCA does not fit better than KRAKEN** with either profile (local searches from the joint MAP and from the best state with KRAKEN; no grid). The accuracy of KRAKEN (Section 30) is not what limits the fit.
- At the joint MAP itself the logger profile gives 190.7 (0.315): the old state is tuned to XBT #11, and a change of 2 m/s in a layer of 20 to 30 m is enough to lose it. A local search with small steps from there (the first attempt, `tloggerStage3.m`) recovered only to 230; the grid was needed.

### 31.6 What this says about the mismatch

- Confirmed by measurement: the lower water column at the array was faster than in XBT #11, and the water at VLA1 is deeper than the joint inversion says. Both pull the estimate of the geometry (water depth, source depth). Correcting the profile gives a small gain in the fit.
- Not explained: most of the gap between 0.46 and 0.70. What the loggers show about its likely nature: the water differs by 2 m/s between two points 3.4 km apart at the same time; a step in the profile moves by 15 m within 45 minutes and by 7 m within 7 minutes at the array. For an internal wave this means structure on a scale of a few hundred metres, shorter than the 1 km path, which neither one profile nor two profiles with adiabatic modes describe. The loggers cover only the lowest third of the column, where the sound speed varies least between the casts (Section 15); the upper 130 m, with gradients several times larger, were not measured at the time of the transmission.
- Still unused in the new ship data: the ADCP (currents and backscatter under the ship during the tow) and, outside this data set, the OOI moorings (Section 22). These are the measurements that could show the upper water column at the time of the tow.
- For the next inversion: the logger profile below the top logger (at the time of each file), a prior of the water depth that extends beyond 205 m, and a higher bound of the thickness.

## 32. Range-dependent run: status on 2026-11-17 at 12:55 PST and the first 10,000 samples

**Status.** Running since 2026-11-15, 23:31 PST, no errors or warnings, no failed proposal. Sample 16,070 of 20,000. The job of the other project ended, and the speed is 600 samples per hour again (15 samples in 90 s); the sampling should end around 19:30 PST, followed by the sensitivity analysis and the final file. The intermediate file with 10,000 samples was written on 2026-11-17 at 00:25 PST.

**First 10,000 samples** (5,000 after a burn-in of 5,000). Evaluated on the server with a scratch script (`/var/tmp/<user>/evalRD/evaluateRangeDependent.m`, which does what `checkHeldOutWindows.m` does and also lists the posterior; copy of the file there with the name `resultsDataEOFRangeDependentTmp_run20261115T2331_10000samples.mat`). The file has not been copied to the MacBook.

| | this run | joint run (Section 13.6) |
|---|---|---|
| logL of the fitted frames at the MAP | 308.14 (sample 9,667) | 296.49 |
| correlation at the MAP, fitted / held out | 0.467 / 0.458 | 0.455 / 0.448 |
| correlation of posterior samples, fitted / held out | 0.460 (0.003) / 0.451 (0.006) | 0.451 (0.003) / 0.443 (0.004) |

| parameter | MAP | mean (std) | 95% interval |
|---|---|---|---|
| source range of frame 1 [m] | 1029.5 | 1028.0 (14.7) | 990.5 to 1051.8 |
| source depth [m] | 124.36 | 124.74 (1.46) | 121.27 to 127.92 |
| tilt [deg] | 0.123 | 0.150 (0.069) | 0.010 to 0.302 |
| water depth [m] | 202.38 | 202.08 (1.80) | 197.22 to 204.81 |
| speedTop [m/s] | 1510.3 | 1517.2 (28.5) | 1461.2 to 1559.5 |
| thickness [m] | 1.40 | 2.51 (1.18) | 0.91 to 4.84 |
| speedH [m/s] | 1580.1 | 1586.7 (10.1) | 1578.0 to 1599.8 |
| sspArray1, 2, 3 | -0.69, 1.94, 1.94 | -0.32 (0.39), 1.09 (0.87), 1.31 (0.51) | |
| sspDifference1, 2, 3 | 0.05, -0.24, -0.72 | -0.00 (0.12), -0.07 (0.27), -0.21 (0.47) | |

- **The gain on the held-out frames is about 0.01** (0.448 to 0.458 at the MAP, 0.443 to 0.451 for the posterior samples), with 6 more unknowns. This is what the local search of Section 16.6 gave (0.458). The fit stays far below the cap of 0.70.
- **The differences between the ends are not resolved:** their posterior standard deviations (0.12, 0.27, 0.47) are close to those of the uniform priors (0.14, 0.29, 0.58). At the MAP itself they matter (with the differences set to zero the MAP has 291.0 and 0.448 / 0.442), but other combinations of the coefficients fit as well.
- The coefficients 2 and 3 at the array lean against the upper bound of 2 (22% and 18% of the samples above 1.8), and the water depth against 205 m (7% above 204.5 m; measured about 204 to 205 m, Section 31.2). The mean range is 2 m from the GPS range.
- Convergence: the means of the first and of the second half agree for all unknowns; the log-likelihood is at its level from the first samples (300.9 in the first 2,000, 301.0 after the burn-in).
- Adiabatic modes: correlation of the paired mode shapes 0.97 to 0.99 at the MAP and at least 0.94 in 20 posterior samples, so the pressure is reliable.
- **The estimated profile does not agree with the loggers.** Profile at the array minus XBT #11 (posterior mean; MAP in brackets): -5.1 (-9.2) m/s at 20 m, +2.3 (+3.5) at 60 m, +0.7 (+1.2) at 80 m, -0.5 to -0.7 (-0.8 to -1.0) at 120 to 160 m, -0.2 (-0.3) at 180 m. The loggers measured the water at the array **faster** than XBT #11 by 1.3 to 2.4 m/s at 158 to 185 m (Section 31.3). The three EOFs describe the variability of the casts, which is largest in the upper water column, and cannot produce the measured difference in the lower layer; the profile they find is an effective one, not the measured one. The profile from the loggers, with no unknown added, gives a better fit of the held-out frames (0.464, Section 31.5) than the MAP of this run (0.458).
- To do when the run has ended: copy the final file to the MacBook (name with the start time `20261115T2331`), and evaluate it as here. Proposal for the next run: the logger profile below the top logger, EOF coefficients for the water above it only, and a prior of the water depth beyond 205 m.

## 33. Tests for the plan of the next inversion, and the plan (2026-11-17)

Florian Meyer asked for a plan of the next inversion and whether a good set of EOFs for a range-dependent profile is the key. Before answering, four short tests were run on the server (scratch script `planTests.m`, logs in `/var/tmp/<user>/plan`; KRAKEN, six fitted frames, local searches from the best state with the logger profile of Section 31.5: logL 312.7, correlation 0.473 fitted and 0.464 held out). No code of the repository was changed.

### 33.1 What the casts and the loggers can provide as a basis

- **Casts, upper water column (0 to 120 m):** standard deviation up to 6 m/s (at 20 m). A cast that is left out is reproduced by the EOFs of the other 17 casts with an rms error of 3.2, 1.8, 1.6, 1.3, 1.1, 1.0, 1.0 m/s for 0 to 6 EOFs. With 18 casts the error does not go below about 1 m/s, whatever the number of EOFs.
- **Casts, lower water column (130 to 200 m):** 0.72, 0.49, 0.35, 0.25, 0.21, 0.18, 0.16 m/s for 0 to 6 EOFs.
- **The EOFs of the casts cannot represent the correction that the loggers measured:** the logger profile minus XBT #11 has an rms of 0.70 m/s over the column; after removing its part along 1 to 6 EOFs of the casts 0.70, 0.70, 0.69, 0.69, 0.65, 0.65 m/s remain. This is why the run with EOF coefficients could not find it (Section 32).
- **Loggers** (17 depths, 4,231 minutes at the shelf break): standard deviation 0.19 to 0.33 deg C per logger (0.6 to 1.1 m/s). EOFs of the logger temperatures: 54, 24, 13, 3, 1.5, 1% of the variance. The difference in space between XBT #11 and the loggers at the same time (rms 0.40 deg C) lies mostly along the first four of them (0.20 deg C left with two, 0.10 with four). The changes in time at the array therefore span the difference in space; the loggers are the right source of a basis for the lower layer.

### 33.2 EOFs of the upper water column on top of the logger profile

Three EOFs of the casts restricted to the water above the loggers (weight 1 down to 110 m, 0 from 130 m; one standard deviation is 2.7, 1.1, 0.9 m/s rms), same at both ends, as three more unknowns (bounds -2 to 2). Local searches of the 10 unknowns from three starts:

| start of the coefficients | logL fitted | correlation fitted / held out | coefficients found |
|---|---|---|---|
| 0, 0, 0 | 313.0 | 0.4735 / 0.4644 | -0.02, -0.08, -1.95 |
| -0.10, -2.0, 0.22 | 313.3 | 0.4738 / 0.4645 | 0.39, -1.63, -1.97 |
| 0.06, 0.76, -0.28 | 312.9 | 0.4733 / 0.4639 | -0.14, 0.31, -1.95 |

- **No gain** over the logger profile alone (312.7, 0.4731 / 0.4641), and the coefficients are not determined: the second one ends anywhere between -1.6 and 0.3 with the same fit, the third one goes to its bound for 0.3 in the log-likelihood. The three profiles differ by several m/s above 40 m; all have about +4 m/s at 50 to 60 m.
- Without the loggers the EOF coefficients had given +6 (Section 16.6) and +12 (Section 32). Most of that gain was a substitute for the correction of the lower layer.
- These are local searches, not an inversion.

### 33.3 Water depth of the echosounder

Water depth fixed at 204.5 m (Section 31.2), logger profile, other 6 unknowns refitted:

| | logL fitted | correlation fitted / held out | range | source depth |
|---|---|---|---|---|
| heights of the mooring diagram | 309.2 | 0.469 / 0.456 | 1029.8 m | 122.1 m |
| height of the array above the seafloor free | 310.2 | 0.470 / 0.456 | 1031.7 m | 122.4 m (array 0.2 m higher) |
| water depth and height free | 312.8 | 0.473 / 0.464 | 1016.8 m | 121.9 m (202.9 m, array 0.05 m higher) |

- With the measured water depth the estimated range is 1029.8 m, at a cost of 3.5 in the log-likelihood. Water depth and range lie on one ridge (correlation 0.95). With XBT #11 the ridge does not reach the measured water depth (243 at 204.5 m, Section 31.5). **Correction of 2026-11-17 (Section 36.3):** the "GPS range" of 1030.4 m in the code is interpolated from three XBT positions; the GPS of the ship gives 1000.5 m for a layback of 180 m. The estimate of 1029.8 m agrees with the GPS of the ship for a layback of about 155 m, which the comparison of the files before and after the closest approach also gives.
- The heights of the mooring diagram need no correction (0.05 to 0.2 m).

### 33.4 Range dependence in the lower layer

Array end: logger profile at 2100Z. Source end: logger profile of another time (a wave that passes the array reaches the source earlier or later), adiabatic modes, 7 unknowns refitted:

| lag [min] | -60 | -40 | -30 | -20 | -10 | 0 | +10 | +20 | +30 | +40 | +60 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| logL fitted | 273.7 | 280.0 | 284.3 | 303.8 | 309.9 | 312.7 | 284.1 | 303.2 | 304.4 | 307.2 | 312.0 |

- **No lag is better than the same profile at both ends.** The profiles of the other times differ from the one at 2100Z by only 0.08 to 0.23 deg C rms, and the fit drops by up to 39. The data are sensitive to the lower layer at the source end and want it as the loggers have it at the array at 2100Z. Together with Section 31.5 (source end towards XBT #11: worse) there is no sign of a range dependence along the 1 km path that the data can resolve.

### 33.5 Assessment

- A better set of EOFs is not where the next gain is. With the measured lower layer, EOFs of the upper water column add nothing and are not determined (33.2); range dependence is not supported in the lower layer (33.4) and was not resolved in the run of Section 32; and 18 casts cannot give a basis that reproduces an unseen profile of the upper water column to better than about 1 m/s (33.1).
- What the new data do give is a consistent picture: logger profile, water depth of the echosounder, GPS range, and a source depth near the nominal 120 m fit together (33.3). The fit stays at about 0.47 / 0.46. The remaining gap to 0.70 is not explained by any description of the water column tried so far; Section 34 shows that about half of it cannot be closed by any static model.

### 33.6 Proposed next inversion (not set up)

Aim: an estimate of the seabed that rests on the measurements, with the geometry checked against independent data. It will not raise the fit much beyond 0.47 / 0.46.

1. **Water profile:** XBT #11 above the top logger; below, the loggers of VLA1 at the time of the frames, moving with the array. No EOF coefficients, same profile at both ends. New code: a reader of the logger files (serial numbers and heights of Section 31.1, offsets from CTD #28) and the profile builder of Section 31.5.
2. **Model:** KRAKEN (ORCA fits no better and is twice as slow).
3. **Unknowns:** the 7 of the joint inversion.
4. **Priors:** water depth Gaussian 204.5 m with a standard deviation of 1 m (echosounder), bounds 198 to 210 m; thickness up to 15 m instead of 5 m (every run leans against 5 m); range as before (GPS, 100 m), so that the estimated range remains a check.
5. **Data:** the six fitted frames of the 2100Z file, the other six held out, as before.
6. **Checks afterwards:** held-out frames; estimated range against GPS and source depth against the nominal depth; the MAP environment with the logger profile of each time on the other files (2030Z, 2110Z to 2130Z) with `MFP.m`.
7. **Cost:** as the joint run, about 2,000 samples per hour on the server, 30,000 samples in about 15 hours.
8. **Second run, if wanted:** the same with the three EOFs of the upper water column as unknowns with a standard normal prior. They do not improve the fit; the run shows how much the uncertainty of the upper water column widens the posterior of the seabed.
- Open decision that affects the posterior widths: the effective number of snapshots (open point 2).

## 34. How much of the gap can a static model close? Repeatability of the measured field (2026-11-17)

Question of Florian Meyer: do we know that the mismatch must come from effects in the water column? Test on the data themselves (scratch scripts `coherenceTest.m` and `coherenceLeaky.m`, `/var/tmp/<user>/plan`): the 12 consecutive frames of the 2100Z file (4.92 s and 5.38 m of source movement from one frame to the next). For each frame and tone, the cap is the largest eigenvalue of the cross-spectral matrix and the dominant vector is its eigenvector, i.e. the best possible replica of that frame.

| | 503 Hz | 653 Hz | 803 Hz | 1003 Hz | 1253 Hz | mean |
|---|---|---|---|---|---|---|
| cap | 0.826 | 0.737 | 0.697 | 0.671 | 0.581 | 0.702 |
| cap from the movement of the source alone within a frame (model, no noise) | 0.998 | 0.996 | 0.994 | 0.992 | 0.988 | |
| model against data, logger profile | 0.522 | 0.478 | 0.478 | 0.455 | 0.411 | 0.469 |
| the same as a share of the cap | 0.63 | 0.65 | 0.68 | 0.68 | 0.70 | 0.67 |
| data: dominant vector of frame k as replica of frame k+1, share of the cap | 0.675 | 0.637 | 0.617 | 0.606 | 0.587 | 0.624 |
| model: replica of frame k against replica of frame k+1 (KRAKEN) | 0.972 | 0.957 | 0.940 | 0.908 | 0.882 | 0.932 |

Mean over the tones for larger lags (in frames):

| lag | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|
| data | 0.624 | 0.455 | 0.305 | 0.225 | 0.168 | 0.161 | 0.180 | 0.207 | 0.173 |
| model | 0.932 | 0.758 | 0.551 | 0.377 | 0.273 | 0.238 | 0.270 | 0.292 | 0.290 |
| data divided by model | 0.67 | 0.60 | 0.55 | 0.60 | 0.62 | 0.68 | 0.67 | 0.71 | 0.60 |

- **The measured field does not repeat from one frame to the next as a static model requires.** The frame of 5 s earlier reaches 62% of what is attainable, where the movement of the source alone would leave 93%. The ratio of data to model is about 0.6 to 0.67 at all lags and all tones: the model describes how the field changes with range, and on top of that a constant share of the dominant field differs from frame to frame.
- Reading: if the dominant vector of a frame is a stable part plus a part that is independent from frame to frame, the stable part carries about 0.8 of it (square root of 0.6 to 0.67). A perfect static model would then reach about 0.8 of the cap, i.e. about 0.55 to 0.57 in the mean over the tones. The present model reaches 0.67 of the cap (0.47).
- **Budget of the received power of a frame** (mean over the tones): about 0.30 is outside the dominant component (noise and changes within the 5 s; the movement of the source explains less than 0.01); about 0.13 is in the dominant component but changes from frame to frame; about 0.57 is stable, of which the model has 0.47. So of the gap between 0.47 and 0.70 roughly half (0.10) is a static mismatch that a better environment could recover, and roughly half (0.13) cannot be recovered by any static environment, whatever profile or EOFs are used.
- The changes are not explained by leaky modes: with ORCA the replicas of consecutive frames have 0.908 (trapped modes), 0.853 (phase speeds up to 1700 m/s), 0.833 (up to 1800 m/s). With the last value the stable part would be 0.87 of the dominant vector and the ceiling 0.61.
- They are not explained by the depth of the source: a source that is 0.5 m deeper changes the replica to 0.97 (503 Hz) to 0.83 (1253 Hz), 1 m to 0.88 to 0.48. This depends strongly on frequency; the repeatability of the data hardly does. The MFP peaks of consecutive frames scatter by 0.33 m in depth (Section 9).
- The cap falls with frequency (0.83 to 0.58). The model reaches about the same share of the cap at all tones (0.63 to 0.70).
- **What is established and what is not.** Established: only changes of the water column have ever raised the fit; the seabed, the geometry, and the propagation model as far as tested have not; and a large part of the mismatch changes within seconds, which only the medium, its surface, or the movement of source and array can do. Not established: the mechanism of these changes (sea surface at 8 to 9 m/s of wind, small-scale structure of the water, movement of the source), and that the static half of the gap is in the water column (the shape of the array was tested afterwards and is not the cause, Section 35). The assumption that the changing part is independent from frame to frame is supported by the ratio that is constant over the lags, but it is an assumption.
- Consequence for the plan of Section 33: unchanged. The target for the fit of a static model is about 0.55 to 0.6, not 0.70.

## 35. Shape of the array (2026-11-17)

Request of Florian Meyer: test the shape of the array, with the work of William Hodgkiss and other models. Scratch script `arrayShapeTests.m` on the server (`/var/tmp/<user>/plan`, logs `log_s1.txt`, `log_s2_*.txt`). Environment and source: best state with the logger profile (Section 31.5; 312.7, correlation 0.473 fitted and 0.464 held out, tilt -0.05 deg). The modes were computed once on a depth grid of 0.1 m, so that the positions of the hydrophones could be changed without new KRAKEN runs. No code of the repository was changed.

**Literature** (abstracts and search summaries only; the full texts could not be opened. The two files in `Papers` are other papers: Michalopoulou and Porter 1996 and Soares and Jesus 2003, both on broadband matched-field processing).
- Hodgkiss, Ensberg, Murray, D'Spain, Booth, Schey, "Direct measurement and matched-field inversion approaches to array shape estimation," IEEE J. Oceanic Eng. 21, 393-401 (1996): a 120 m vertical array in about 200 m of water (SWellEx-3); shape from tilt and heading sensors, from transponders, and from matched-field inversion with a towed source of 50 to 200 Hz; the three agree, with residuals mostly below 1 m.
- Tran and Hodgkiss, "Array surveying using matched-field processing," J. Acoust. Soc. Am. 94, 2851-2858 (1993): with a source of known position and a known environment, the positions of the hydrophones are found by maximizing the Bartlett output.
- D'Spain, Murray, Hodgkiss, Booth, Schey, "Mirages in shallow water matched field processing," J. Acoust. Soc. Am. 105, 3245 (1999): a tilt of the array or a wrong bathymetry moves the estimated source position.
- VLA1 carried three tilt, heading, and depth sensors (trip report, App. B.3). Their data are not in `Matlab/Data`; they would be the direct measurement.

**Models tested**

| model | free | logL fitted | correlation fitted / held out | values found |
|---|---|---|---|---|
| straight array (as in the code) | tilt | 312.7 | 0.4731 / 0.4641 | -0.05 deg, one maximum only |
| tilt and bow (parabola, the shape of a taut mooring in a uniform current) | 2 | 312.8 | 0.4732 / 0.4666 | -0.06 deg, -0.05 m |
| tilt, bow, S-shape, stretch | 4 | 313.1 | 0.4736 / 0.4655 | -0.04 deg, -0.03 m, -0.01 m, 0.02% |
| the same, 7 unknowns refitted with it (KRAKEN run per step) | 7 + 2 | 313.1 | 0.4736 / 0.4659 | bow -0.03 m, stretch 0.05% |
| horizontal position of each hydrophone (Tran and Hodgkiss) | 15 | 315.6 | 0.4753 / 0.4643 | all within 0.05 m of the line |
| depth of each hydrophone | 16 | 320.4 | 0.4811 / 0.4638 | -0.6 to +0.4 m, most within 0.3 m |
| horizontal position and depth of each hydrophone | 31 | 324.1 | 0.4841 / 0.4654 | |
| tilt of each frame separately | 12 | | +0.004 on average | -0.26 to +0.02 deg |

- **The array is straight and where the diagram puts it.** The data are very sensitive to its shape: 0.25 deg of tilt (0.25 m at the top) costs 25 in the log-likelihood, 0.5 deg costs 85, a bow of 0.1 m costs 7, of 0.25 m 34, a stretch of 1% costs 13. Within this resolution the best shape is the straight line with -0.05 deg: bow 3 cm, stretch 0.05%, each hydrophone within 5 cm of the line.
- **No shape model raises the fit of the held-out frames.** The free depths raise the fitted frames by 8 and the held-out frames not at all: they fit the noise.
- A tilt that differs from frame to frame (up to 0.26 deg) explains 0.004 of the correlation.
- **Hydrophones:** received power against the model within about 2 dB for all 16 (mean over the tones; hydrophones 3 to 5 are 1.6 to 2.2 dB above the model, with 2 to 3 dB of scatter over the tones). No hydrophone is dead, inverted, or exchanged with another (largest mean phase difference to the replica 76 deg, none near 180 deg). Leaving out one hydrophone changes the correlation of all frames from 0.469 to between 0.460 and 0.483 (the largest gain, 0.014, without the top hydrophone).
- **Phases:** the phase of the measured dominant vector against the replica at a hydrophone is not the same in all frames (consistency 0.71 to 0.80, where 1 would be identical), and its mean over the frames is not proportional to frequency (an offset of a hydrophone would be). The residual is not a geometric error of the array; it changes from frame to frame, as in Section 34.
- Not tested: a tilt out of the vertical plane through the source. It changes the ranges of the hydrophones only to second order and cannot be seen with one source direction.
- **Result: the shape of the array, the positions of the hydrophones, and their calibration are not a cause of the mismatch.**

## 36. Is something major overlooked? Conventions, ambiguity surfaces, ship track, longer ranges (2026-11-17)

Question of Florian Meyer: which other tests could show what would improve the fit; the MFP plots do not show a clear maximum at the source. Scratch scripts on the server (`ambiguityTest.m`, `ambiguityFiles.m`, `mirageTest.m`, `rangeDependentFiles.m` in `/var/tmp/<user>/plan`; the five other acoustic files of JD 147 were copied to `/var/tmp/<user>/plan/acoustic`). Environment unless stated: best state with the logger profile (Section 31.5), loggers of the time of each file. No code of the repository was changed. Two figures were added: `MFP/Results/SBCEX22_VLA1_2100Z_MFP_data_and_simulation.png` and `MFP/Results/SBCEX22_VLA1_MFP_files_logger_profile.png` (from the scratch scripts, not from `MFP.m`).

### 36.1 Conventions of the data

Search over range, source depth, and tilt with the data of the 2100Z file as they are, complex conjugated, with the channels in reverse order, and both: highest correlation 0.469 (1015 m, 121.75 m), 0.103, 0.130, 0.136. The sign convention of the spectra and the assignment of channel 1 to the deepest hydrophone are right.

### 36.2 Ambiguity surface of the 2100Z file against a simulation

Bartlett output over 500 to 3000 m and 1 to 199 m, mean over the 5 tones and the 12 frames (the range of each frame follows the track). Simulation: same environment, noise-free field of a source at the estimated position.

| | data | simulation |
|---|---|---|
| value at the source | 0.464 (global maximum, at 1020 m and 122 m) | 0.989 |
| highest value away from the source | 0.316 (1985 m, 2 m) | 0.593 (same place) |
| ratio | 0.68 | 0.60 |
| ratio for one frame | 0.74 | 0.66 |
| ratio for 503 Hz alone / 1253 Hz alone | 0.87 / 0.84 | 0.82 / 0.68 |

- For this file the surface has one clear maximum at the source, and its side lobes are where the simulation has them and almost as low relative to the peak (first figure). With 16 hydrophones over a quarter of the water column, a side lobe at 0.6 of the peak is the best this array can do with five tones; a single tone is ambiguous even in the simulation.

### 36.3 Source track from the GPS of the ship

`getSourceTrackMFP.m` interpolates the position of the ship linearly between the launches of XBT #9 to #11 (1932Z, 2033Z, 2133Z). The new ship data contain the GPS of the ship (`underway/raw`, C-Nav for 20Z to 21Z, DPS-112 for 21Z to 22Z; no GPS file for 19Z to 20Z in this subset). The track passes 240 to 280 m south of VLA1 at about 2043Z; speed 1.02 to 1.24 m/s. Source 180 m behind the ship (straight-line distance to the earlier position of the ship; the distance summed along the track is longer by a few percent because of the motion of the antenna and gave 1008 m at 2100Z in a first version of this table), at the start of each file:

| time | 2030Z | 2100Z | 2110Z | 2120Z | 2130Z |
|---|---|---|---|---|---|
| range from the GPS of the ship | 1004.9 m | 1000.5 m | 1640.9 m | 2299.5 m | 2994.7 m |
| its rate of change in the first minute | -1.08 m/s | 1.06 m/s | 1.19 m/s | 1.20 m/s | 1.12 m/s |
| range in the code | 1008 m | 1030.4 m | 1691 m | 2357 m | 3023 m |

- The ranges of the code are 28 to 58 m too long from 2100Z on. The prior of the range in the inversion (100 m) is wide enough for this. The step from frame to frame at 2100Z is 5.2 m, against 5.38 m in the code (`scenario.sourceRangeOffsets`); by frame 12 the range of the code is 1.9 m too long relative to frame 1. The joint inversions used the steps of the code.
- **Layback.** At 2030Z the source approaches the array, at 2100Z it leaves it, both at about 1 km. The MFP ranges are 975 m and 1020 m. If the model has the same relative error of the range in both files, the source is about 25 m closer to the ship than assumed (layback about 155 m instead of 180 m; the range grid of 5 m limits this to a few metres), and the relative error is -0.5% (with the water depth of the echosounder, Section 33.3, about +1%).

### 36.4 All files of JD 147

Highest Bartlett output near the source (second figure). Ratio: highest value elsewhere over this value. Range from the GPS of the ship with a layback of 155 m.

| file | range (GPS, layback 155 m) | logger profile: value, range, depth | range over GPS | ratio | joint MAP with XBT #11: value |
|---|---|---|---|---|---|
| 2030Z | 981 m | 0.412, 975 m, 124 m | 0.99 | 0.74 | 0.387 |
| 2100Z | 1025 m | 0.464, 1020 m, 122 m | 1.00 | 0.68 | 0.447 |
| 2110Z | 1666 m | 0.294, 1595 m, 115 m | 0.96 | 0.90 | 0.323 |
| 2120Z | 2325 m | 0.267, 2205 m, 111 m | 0.95 | 0.78 | 0.259 |
| 2130Z | 3020 m | 0.223, 2860 m, 119 m | 0.95 | 0.91 | 0.218 |

- The 1930Z file (source at about 5 km) was outside the search (300 to 4500 m).
- At 1 km on both sides of the array the maximum is at the source. **At 1.7 to 3 km the maximum is 4 to 5% short in range and 3 to 11 m too shallow**, the value drops to 0.22 to 0.29, and side lobes come within 10% of it. The logger profile of the time of the file helps at 2030Z and 2100Z and not at the longer ranges.
- **Sloping seabed** (water depth linear between array and source, adiabatic modes with the wavenumbers integrated along the path; slopes of -4 to 7 m per km): at 2100Z slopes of 0 to 2 m per km fit equally (0.462 to 0.464) and 2 to 3 m per km put the maximum on the GPS range, in agreement with the echosounder (1.4 to 2.1 m per km, Section 31.2). At the longer ranges a slope moves the maximum towards the GPS range and the source depth towards 120 m, but the value falls (2110Z: 0.294 flat, 0.251 at 3 m per km; 2120Z: 0.267 and 0.208); only at 2130Z it rises slightly (0.223 flat, 0.231 to 0.240 at 3 to 4 m per km, maximum at 2995 to 3040 m and 124 to 126 m).
- **Profile of XBT #11 at the source end** (adiabatic modes; XBT #11 was launched at 2132Z, 3.4 km east of VLA1, next to the source of the 2130Z file): the value falls at all three ranges (2110Z: 0.294 to 0.215; 2120Z: 0.267 to 0.195; 2130Z: 0.223 to 0.207).
- All tests of a range dependence so far use adiabatic modes paired by their index (Sections 16.3, 31.5, 33.4 and here). The profile has two ducts, and whether this approximation holds for these changes along the path has only been checked through the similarity of the mode shapes. A run with coupled modes or a parabolic equation has not been made.

### 36.5 Tests proposed (tests 1 to 6 run afterwards, Section 37)

1. **What does a file at longer range ask for?** Fix the range at the GPS value (layback 155 m) and the source depth at 122 m for the 2120Z file, and refit water depth, seabed, and tilt. If one of them moves far (for example a slower seabed at the top), that is the property the 1 km file cannot see. Then apply the result to 2100Z.
2. **One inversion for several ranges** (2030Z, 2100Z, 2110Z, 2120Z), ranges tied by the GPS of the ship, with the layback as an unknown.
3. **Coupled modes or parabolic equation** through the measured bathymetry and the two measured profiles for the 2130Z file, against the adiabatic result. This decides whether the tests of range dependence can be trusted.
4. **Arrival angles:** beamform the array vertically for each file and compare the power against angle with the model. This does not depend on the phases between the arrivals and shows which group of arrivals is wrong in strength.
5. **Repeatability at the other ranges** (Section 34 for each file) and against the wind of the ship's log: if the part that changes from frame to frame grows with range and with frequency, the sea surface is the likely cause.
6. **Processors that combine the tones coherently** (Michalopoulou and Porter 1996 and Soares and Jesus 2003, both in `Papers`): lower side lobes in the MFP plots; they do not raise the fit.
7. The tilt and depth sensors of the array, the depth sensor of the source, and the record of the tow cable, if they can be obtained.

Tests 1 to 6 were run on the same day: Section 37.

## 37. Results of the tests of Section 36.5 (2026-11-17)

Request of Florian Meyer: continue with the tests of Section 36.5. Scratch scripts on the server in `/var/tmp/<user>/tests2` (`pt_setup.m` and four helpers, `longRangeFit.m`, `jointRangeFit.m`, `coupledModeTest2.m` with `cm_segments.m` and `cm_fields.m`, `coupledCheck.m`, `coupledCheck2.m`, `beamTest.m`, `repeatFiles.m`, `snrTest.m`, `coherentTest.m`; one log `log_<label>.txt` for each run). Unless stated: environment of the best state with the logger profile (Section 31.5: water depth 202.8 m, top of the layer 1555.8 m/s, thickness 4.9 m, halfspace 1595.9 m/s, tilt -0.05 deg), logger profile of the time of each file, range of each frame from the GPS of the ship with a layback of 155 m (Section 36.3), 12 frames per file, of which frames 1, 3, ..., 11 are fitted and the others held out. Bounds for the refits: water depth 195 to 212 m, thickness 0.5 to 15 m. No code of the repository was changed. Two figures were added: `MFP/Results/SBCEX22_VLA1_vertical_beams.png` and `MFP/Results/SBCEX22_VLA1_MFP_coherent_tones.png`.

### 37.1 Repeatability and noise at all ranges (test 5)

As Section 34, for each file. Tone over background: power of the tone bin over the mean of the neighbouring bins in single snapshots of 0.66 s, range over the five tones. Wind: true wind of the ship's log.

| file | range | wind | tone over background | cap | frame k as replica of frame k+1 (share of the cap) | the same for the model | stable part |
|---|---|---|---|---|---|---|---|
| 2030Z | 978 m | 6.3 m/s | 36 to 44 dB | 0.664 | 0.59 | 0.93 | 0.79 |
| 2100Z | 1027 m | 9.2 m/s | 36 to 44 dB | 0.702 | 0.63 | 0.94 | 0.82 |
| 2110Z | 1669 m | 9.1 m/s | 24 to 31 dB | 0.689 | 0.62 | 0.94 | 0.82 |
| 2120Z | 2328 m | 8.6 m/s | 33 to 38 dB | 0.702 | 0.70 | 0.96 | 0.85 |
| 2130Z | 3023 m | 8.1 m/s | 34 to 38 dB | 0.724 | 0.74 | 0.96 | 0.88 |

- **Noise is not the reason for the cap of 0.70.** The tones are 24 to 44 dB above the background, which has no dominant component of its own (largest eigenvalue 0.1 to 0.27 of its power). This includes the noise of the tow ship. The 2110Z file has 10 dB less than the others and the same cap. The 0.30 of the power outside the dominant component is the signal itself, changing within the 5 s of a frame (Section 19: the cap falls steadily with the length of the frame, 0.97 for 1 s, 0.88 for 2 s, 0.70 for 5 s).
- **The cap and the repeatability do not get worse with range** (the stable part rises from 0.79 to 0.82 at 1 km to 0.88 at 3 km), and they are not better at 2030Z with less wind (the wind only varies between 6.3 and 9.2 m/s, so this is a weak test). Scattering along the path (sea surface, small structure of the water) would grow with range. The fast changes therefore arise at the source or at the array. The first candidate is the motion of the towed source in the swell; Section 34 found that a change of the source depth alone depends more on frequency than the repeatability does, so this is not confirmed. The depth sensor of the source would decide it (test 7 of Section 36.5). **Withdrawn in Section 38:** the depth sensor of the source was found on the data server and rules out the vertical motion of the source, and the argument from the range does not exclude the sea surface.
- A static model can reach about 0.8 of the cap at all ranges (Section 34).

### 37.2 What do the files at longer range ask for? (test 1)

Refit of single files, started from the environment of the 2100Z file. Correlation of the fitted / held-out frames.

| free | 2110Z (1669 m) | 2120Z (2328 m) | 2130Z (3023 m) |
|---|---|---|---|
| nothing (environment of 2100Z, GPS range, 122 m) | 0.070 / 0.076 | 0.134 / 0.144 | 0.118 / 0.117 |
| range and source depth | 0.296 / 0.293 (-78 m, 115.0 m) | 0.257 / 0.273 (-124 m, 110.9 m) | 0.224 / 0.224 (-162 m, 118.8 m) |
| tilt, water depth, seabed (GPS range, 122 m) | 0.258 / 0.237 | 0.245 / 0.249 | 0.229 / 0.214 |
| source depth, tilt, water depth, seabed (GPS range) | 0.294 / 0.290 | 0.256 / 0.273 | 0.243 / 0.237 |
| all seven | 0.324 / 0.323 | 0.296 / 0.318 | 0.302 / 0.294 |

Values found (water depth, top of the layer, thickness, halfspace):

| free | 2110Z | 2120Z | 2130Z |
|---|---|---|---|
| tilt, water depth, seabed | 196.4 m, 1496 m/s, 7.0 m, 1574 m/s | 208.1 m, 1597 m/s, 13.7 m, 1552 m/s | 205.9 m, 1450 m/s, 3.9 m, 1686 m/s |
| source depth, tilt, water depth, seabed | 116.8 m; 206.3 m, 1510 m/s, 4.8 m, 1572 m/s | 112.2 m; 206.3 m, 1511 m/s, 9.9 m, 1568 m/s | 120.3 m; 205.5 m, 1464 m/s, 3.2 m, 1622 m/s |
| all seven | -72 m, 115.2 m; 202.9 m, 1534 m/s, 4.7 m, 1568 m/s | -121 m, 110.9 m; 202.2 m, 1532 m/s, 14.9 m, 1550 m/s | -328 m, 116.1 m; 196.9 m, 1560 m/s, 11.0 m, 1561 m/s |

- **No range-independent environment of this family brings a file at 1.7 to 3 km above 0.32**, even with all seven values free for that file alone. At 1 km the same freedom gives 0.47. The cap is the same (Section 37.1). As a share of the cap: 0.67 at 1 km, 0.42 to 0.47 at 1.7 to 3 km. **The model error grows with range; the quality of the data does not fall.**
- The refits do not point to a property of the seabed that the 1 km file cannot see. The values scatter (top of the layer 1450 to 1597 m/s, thickness 3 to 15 m, halfspace 1550 to 1686 m/s), and each of these environments is worse on the 2100Z file (0.19 to 0.41 with range and depth refitted, against 0.47).
- With the range at the GPS value and the source depth free, all three files ask for deeper water (205.5 to 206.3 m) and a slower seabed. Deeper water is what a seabed that slopes down towards the source gives as a mean over the path (Section 37.4); the slower seabed may compensate for the same slope and is not taken as a result.

### 37.3 One environment for four files (test 2)

2030Z, 2100Z, 2110Z, 2120Z together: one environment, one source depth, one layback; ranges from the GPS. Two local searches from different starts.

| | log-likelihood (fitted frames) | fitted, per file | held out, per file | values |
|---|---|---|---|---|
| environment of 2100Z, layback 155 m, 122 m | 455.5 | 0.164, 0.412, 0.070, 0.134 | 0.181, 0.402, 0.076, 0.144 | |
| search 1 | 679.1 | 0.420, 0.427, 0.105, 0.157 | 0.415, 0.420, 0.092, 0.158 | layback 146.9 m, source 123.9 m, tilt -0.07 deg, water depth 202.2 m, top 1520 m/s, thickness 2.8 m, halfspace 1605 m/s |
| search 2 | 647.9 | 0.382, 0.449, 0.066, 0.160 | 0.377, 0.436, 0.068, 0.181 | layback 146.6 m, source 122.9 m, tilt -0.07 deg, water depth 203.9 m, top 1554 m/s, thickness 5.2 m, halfspace 1609 m/s |

- **One environment fits both files at 1 km**, held-out frames included (0.42 and 0.42), although the source approaches on one side of the array at 2030Z and leaves on the other at 2100Z. The pair determines the layback, because it lengthens one range and shortens the other: 147 m in both searches (155 m in Section 36.3 from the MFP ranges; assumed in the code 180 m).
- The files at 1.7 and 2.3 km stay at 0.07 to 0.16. A range-independent model with the measured ranges cannot serve 1 km and 2 km together, so a joint inversion over these ranges is not useful with the present forward model.

### 37.4 Coupled modes against adiabatic modes (test 3)

**Method.** One-way coupled modes: the path is cut into 40 segments; the modes of each segment come from KRAKEN on a lattice of 0.25 m through water and layer and are continued into the halfspace with their exponential tails; at the end of each segment the field is projected onto the modes of the next segment (integral over depth with the weight 1/density). Modes with a phase speed within 0.75 m/s of the halfspace speed are left out: their tails are too long to be integrated, and a first version that kept them was unstable (`coupledModeTest.m`, energy not conserved; its numbers are not used). Adiabatic: modes paired by their index, wavenumbers summed along the path, as in `getPressuresFromStateSBCEXP22.m` and in all earlier tests.

**Checks.** Without a change along the path the two are identical (1.000). 40 against 80 segments: field correlation 0.9999 at 2100Z and 0.994 to 0.9995 at 2130Z, for profile and seabed changing together. 10 segments against 80: 0.997 to 0.999 at 2100Z, 0.85 to 0.97 at 2130Z.

**Environment along the path**, linear from the array to the source. Profile at the source: the logger profile plus the share range/3380 m of the difference to XBT #11 (XBT #11 was launched 3380 m from the array; 30%, 49%, 69%, 89% for the four files; the two profiles differ below about 130 m only). Seabed at the source deeper by an assumed 2.0, 1.8, 2.4, 3.0 m per km (echosounder near the array: 1.4 to 2.1 m per km, Section 31.2; the value for 2130Z is the one that Section 36.4 found with adiabatic modes). Search over a shift of the GPS range and the source depth; value of the maximum (shift, source depth).

| file | case | coupled against adiabatic field, range over the tones | adiabatic: maximum | coupled: maximum |
|---|---|---|---|---|
| 2100Z | no change | 1.00 | 0.466 (-8 m, 122 m) | 0.466 (-8 m, 122 m) |
| | profile | 0.61 to 0.99 | 0.420 (-13 m, 122 m) | 0.465 (-10 m, 122 m) |
| | seabed | 0.95 to 0.99 | 0.464 (0 m, 123 m) | 0.454 (0 m, 123 m) |
| | both | 0.56 to 0.92 | 0.419 (-3 m, 123 m) | 0.449 (+10 m, 124 m) |
| 2110Z | no change | 1.00 | 0.297 (-79 m, 115 m) | 0.298 (-79 m, 115 m) |
| | profile | 0.73 to 0.91 | 0.233 (-25 m, 118 m) | 0.299 (-21 m, 118 m) |
| | seabed | 0.87 to 0.98 | 0.262 (-46 m, 117 m) | 0.283 (-46 m, 117 m) |
| | both | 0.59 to 0.74 | 0.221 (0 m, 120 m) | 0.284 (+4 m, 120 m) |
| 2120Z | no change | 1.00 | 0.265 (-122 m, 111 m) | 0.264 (-122 m, 111 m) |
| | profile | 0.64 to 0.78 | 0.191 (-122 m, 112 m) | 0.256 (-122 m, 111 m) |
| | seabed | 0.67 to 0.97 | 0.221 (-64 m, 114 m) | 0.238 (-58 m, 114 m) |
| | both | 0.64 to 0.76 | 0.200 (-58 m, 114 m) | 0.242 (-58 m, 114 m) |
| 2130Z | no change | 1.00 | 0.221 (-166 m, 119 m) | 0.220 (-166 m, 119 m) |
| | profile | 0.67 to 0.80 | 0.195 (-159 m, 120 m) | 0.246 (-106 m, 119 m) |
| | seabed | 0.48 to 0.90 | 0.230 (-30 m, 124 m) | 0.213 (+30 m, 123 m) |
| | both | 0.63 to 0.72 | 0.236 (-23 m, 125 m) | 0.240 (+30 m, 124 m) |

- **The adiabatic approximation with modes paired by their index does not hold for a profile that changes along the path.** At 1 km, 30% of the difference to XBT #11 (0.4 to 0.7 m/s in the lowest 70 m) is enough: the adiabatic field has a correlation of 0.61 (1253 Hz) to 0.99 with the coupled field. At 1.7 to 3 km it is 0.6 to 0.9 at all tones. For a sloping seabed alone it holds at 1 km (0.95 to 0.99) and less at 3 km.
- **The earlier result that a profile changing towards XBT #11 lowers the fit (Sections 31.5, 33.4, 36.4) was an effect of the approximation.** The adiabatic model loses 0.03 to 0.07 as soon as the profile changes; with coupled modes the fit stays (2100Z: 0.465 against 0.466). The data neither ask for this change of the profile nor reject it.
- **Consequence for the running range-dependent inversion** (`mainData14L1HRangeDependent.m`, adiabatic modes with two KRAKEN runs): whenever the coefficients of the difference between the two ends are not zero, its field is not reliable to the degree shown above. The posterior of these coefficients should not be interpreted, and the run cannot tell whether a range-dependent profile helps. A range-dependent profile has therefore not had a fair test yet. **Made more precise on the same day** (scratch script `evaluateCoupledAtMap.m` in `/var/tmp/<user>/evalRD`, first 10,000 samples of the run): for the states that the run visited, the differences between the two ends are small (at most about 0.5 m/s at 150 m), and there the field of the code agrees with coupled modes (correlation 0.95 to 1.00 per tone, mean 0.992 over the MAP and 12 posterior samples; fit to the data 0.461 / 0.452 with the code and 0.460 / 0.451 with coupled modes). So the samples of the run are computed correctly. What remains is the other half: larger differences are penalized by the approximation (0.420 instead of 0.465 for the change tested above), so the run could not have found them, and its preference for small differences is partly an effect of the approximation.
- **With coupled modes and the measured changes the maximum at the longer ranges moves to the measured position**: the range error goes from -79, -122, -166 m to +4, -58, +30 m and the source depth from 115, 111, 119 m to 120, 114, 124 m. The position error of Section 36.4 is the mirage effect of bathymetry and profile (D'Spain et al. 1999). At these ranges the surfaces have several maxima of similar height (Section 37.6), so the positions are indicative.
- **The value of the maximum does not rise** (0.28, 0.24, 0.24 against 0.30, 0.26, 0.22 without a change). A linear transition between the two measured profiles over a constant slope is not what is missing at 1.7 to 3 km.
- Cost in an inversion: one KRAKEN run for each segment with the mode shapes on a lattice. 10 segments are enough at 1 km, i.e. about five times the KRAKEN runs of the present range-dependent run (not timed).

### 37.5 Arrival angles (test 4)

Plane-wave beamforming over depth for each tone, power averaged over the 12 frames, data against model (first figure: 2100Z and 2120Z). The spacing of 3.75 m is 1.3 to 3.1 wavelengths, so the pattern repeats beyond 23.6 deg (503 Hz) to 9.2 deg (1253 Hz), and steeper arrivals fold into this interval.

- **At 1 km the arrivals come from the modelled directions.** At 2030Z and 2100Z the strongest beams of the data are in the model at the same angle within 0.5 deg (2100Z, 503 Hz: -6.5, +14.8, +3.2 deg in the data, -6.4, +14.6, +3.0 deg in the model; positive is from above). By their angles these are the paths reflected once at the seabed, once at the surface, and the direct path. One exception: at 2030Z and 503 Hz the data have a beam at -21 deg with 0.93 of the strongest that is not among the three strongest of the model.
- At 503 to 803 Hz the arrival from the surface is 1 to 3 dB stronger in the data, relative to the arrival from the seabed, than in the model, in both files at 1 km. At 1003 and 1253 Hz the data have two to three times the share of the power near the horizontal (0.12 to 0.18 against 0.04 to 0.08).
- Between the arrivals the data have a floor 5 to 8 dB below the strongest beam, where the model has 10 to 20 dB: power from all directions, the part outside the dominant component (Section 37.1).
- At 2110Z to 2130Z the beams of the data are present in the model, but their order of strength differs. At 2110Z the strongest beam of the data (-4.5 deg) is the second or third of the model at four tones. At 2130Z the strongest beam of the data comes from above at all five tones (+4 to +8 deg), that of the model from below at four of five (-5 to -10 deg); the share of the power from above is 0.50 to 0.59 in the data and 0.41 to 0.51 in the model.
- Both observations have the same sign: sound that has just been reflected at the seabed is weaker in the data, relative to the rest, than in the model. This could mean a seabed that reflects less at 5 to 10 deg grazing than the modelled one. The densities and attenuations of the seabed were never estimated (Section 3.4: fixed at 1.6, 1.8, 1.85 g/cm^3 and 0.3, 0.55, 0.65 dB/(m kHz)); test in Section 37.7.
- So the vertical structure of the field is largely right at 1 km; the mismatch is in the phases between the arrivals, their relative strength by a few dB, and the part that changes within a frame.

### 37.6 Tones combined coherently (test 6)

After Michalopoulou and Porter 1996 (`Papers/JOE-1996.pdf`): for each frame and tone the dominant vector of the data and the replica are referred to the phase at one hydrophone, which removes the unknown phase of the source; the products of replica and data are then summed over the tones before the magnitude is taken. Here the result is averaged over the 16 choices of the reference hydrophone and over the 12 frames. Search over 500 to 4000 m and 2 to 198 m. "Near the source": 0.88 to 1.06 of the GPS range and 100 to 140 m. Simulation: noise-free field of a source at the position of the maximum, same environment. Second figure: both surfaces for all five files.

| file | mean of the tones (as in the MFP plots): maximum near the source | highest value elsewhere over this maximum, data / simulation | tones combined coherently: maximum near the source | highest value elsewhere over this maximum, data / simulation |
|---|---|---|---|---|
| 2030Z | 0.412 | 0.66 / 0.68 | 0.328 | 0.54 / 0.44 |
| 2100Z | 0.468 | 0.67 / 0.60 | 0.423 | 0.54 / 0.44 |
| 2110Z | 0.294 | 0.79 / 0.36 | 0.164 | 0.77 / 0.15 |
| 2120Z | 0.264 | 0.69 / 0.37 | 0.139 | 0.64 / 0.18 |
| 2130Z | 0.223 | 0.85 / 0.39 | 0.106 | 0.75 / 0.18 |

- In all five files the global maximum is the one near the source.
- **At 1 km the coherent combination gives a clearer maximum**: the highest side lobe falls from 0.66 to 0.67 of the maximum to 0.54, and the area of the surface above half the maximum from 0.15% to 0.01% or less. At the longer ranges the ratio changes little (0.69 to 0.85 becomes 0.64 to 0.77); the area above half the maximum shrinks by a factor of 5 to 17 (2130Z: 4.1% to 0.3%).
- **The simulation shows what limits the plots at the longer ranges.** With a correct model the highest side lobe would be at 0.36 to 0.39 of the maximum (0.15 to 0.18 with the coherent combination). In the data it is at 0.7 to 0.85 because the maximum itself is only 0.22 to 0.29; the side lobes are not higher than expected (0.18 to 0.23 in absolute value, against 0.36 to 0.39 in the simulation). The missing clear maximum is the low fit seen from another side, and no processor repairs it.
- With one fixed reference hydrophone the result depends on the hydrophone (ratio 0.47 to 0.74 at 1 km); the mean over the references is steadier. Choosing the phases of the tones anew at each position gives nothing (0.63 to 0.64).
- Not tested: combining the frames coherently with constant phases of the source. This needs the single snapshots with their exact times and the exact frequencies of the tones.

### 37.7 Densities and attenuations of the seabed (follow-up of the arrival angles)

Scratch script `seabedFit.m`, logs `log_seabed_<file>.txt`. Refit of single files as in Section 37.2, with the densities and attenuations of layer and halfspace free in addition (bounds 1.0 to 2.6 g/cm^3, halfspace to 2.8, and 0 to 3 dB/(m kHz)). Correlation of the fitted / held-out frames.

| free | 2030Z | 2100Z | 2110Z | 2130Z |
|---|---|---|---|---|
| range and source depth | 0.420 / 0.408 | 0.474 / 0.466 | 0.296 / 0.293 | 0.224 / 0.224 |
| and the three attenuations | 0.428 / 0.418 | 0.475 / 0.466 | 0.330 / 0.329 | 0.232 / 0.231 |
| and the three densities | 0.425 / 0.414 | 0.475 / 0.468 | 0.299 / 0.295 | 0.227 / 0.226 |
| and both | 0.428 / 0.419 | 0.476 / 0.469 | 0.330 / 0.330 | 0.232 / 0.231 |
| geometry, speeds, thickness (7 values) | 0.447 / 0.449 | 0.474 / 0.465 | 0.324 / 0.323 | 0.292 / 0.285 |
| all 13 | 0.449 / 0.454 | 0.478 / 0.469 | 0.341 / 0.338 | 0.295 / 0.287 |

- **The densities and attenuations are not what is missing.** At 1 km they add 0.002 to 0.005 to the seven values, at 1.7 km 0.02, at 3 km 0.003. The values found run to the bounds and differ from file to file (halfspace attenuation 0.19 and 3.0 for the two files at 1 km), i.e. the data do not determine them. Keeping them fixed (Section 3.4) is justified.
- The largest gain, 0.034 at 2110Z with attenuations of 2.6 and 3.0 dB/(m kHz), lowers the fit of the 2100Z file from 0.474 to 0.425 when applied there.
- The difference in the strength of the arrivals (Section 37.5) is therefore not removed by a seabed of this family that absorbs more.
- Side result: the 2030Z file alone prefers a thin, slow layer (1.75 m, 1490 m/s over 1620 m/s; 0.447 / 0.449 against 0.420 / 0.408 with the environment of 2100Z). That environment gives 0.444 / 0.430 on the 2100Z file. Each of the two files at 1 km thus loses 0.03 to 0.04 with the best environment of the other; whether the seabed differs between the two sides of the array or the layer is not determined at this level was not examined.

### 37.8 What the tests say together

1. The data are good at all ranges: 24 to 44 dB above the noise, the same cap, the same or better repeatability. Where the fast changes arise that keep a static model at about 0.8 of the cap is open: the conclusion of Section 37.1 (source or array) is withdrawn, see Section 38.
2. The model error grows with range: 0.67 of the cap at 1 km, 0.42 to 0.47 at 1.7 to 3 km for the best range-independent environment of each file. An error that grows with range while the data stay the same is an environment that changes along the path, or errors of the wavenumbers that add up with range. It is not the array, the processing, or noise.
3. The measured part of that change (slope of the seabed, profile towards XBT #11), with coupled modes, puts the maximum at the measured position and does not raise it.
4. The adiabatic approximation in the code is not valid for a profile that changes along the path. The tests of range dependence before this section and the running inversion are affected.
5. At 1 km the MFP surface has a clear maximum at the source on both sides of the array, and one environment serves both sides at 0.42 (each side alone: 0.45 and 0.47). The unclear maxima are those of the longer ranges and follow from point 2.
6. The densities and attenuations of the seabed, which were never estimated, are not the cause (Section 37.7).

Not explained: the static part of the gap at 1 km (0.47 against about 0.55 to 0.6 attainable), and the loss between 1 km and 1.7 km.

Next steps proposed (not done; Florian Meyer decides):
- The 7-unknown inversion of the 2100Z file with the logger profile (Section 33.6) is not affected by point 4 and stands as planned.
- Before any further inversion with a range-dependent profile: replace the adiabatic modes by coupled modes in the forward model.
- Simulate how much of the loss between 1 and 3 km the variability of the water can cause: coupled modes through profiles that vary along the path as the loggers of VLA1 and VLA2 vary in time.
- Ask for the tilt and compass sensors of the array (test 7 of Section 36.5). The depth sensor of the source was found on the data server afterwards (Section 38).

## 38. Data on the data server of the experiment: source depth, swell, bathymetry; phases of the arrivals (2026-11-17)

Question of Florian Meyer: is it certain that the depth sensor of the source and the tilt sensors of the array are not available? It was not: they had only been looked for in `Matlab/Data` on this Mac. The experiment folder `SBCEXP22` on the data server of the experiment holds more (login with two factors by Florian Meyer; read only). Scratch scripts on the compute server in `/var/tmp/<user>/tests2`: `sourceDepthTest.m`, `beamPhaseTest.m`, `sectorTest.m`, `bathyTest.m`. No code of the repository was changed. One figure was added: `MFP/Results/SBCEX22_VLA1_arrival_phases.png`.

### 38.1 What is there and what was copied

| measurement | in the experiment folder | copied to `Matlab/Data` |
|---|---|---|
| depth of the source | `processed/sourceDepth`: one file per day with `dTime` and `depth`, 1 s averages of a sensor sampled at 25 kHz; plots | yes |
| compass and tilt sensors of the arrays (Starmon; on VLA1 SCL0003, SCL0004, SCL0012, 0.5 m below hydrophones 16, 9, 1) | only their positions (`documents/VLA1_HOBO_Staroddi_Locations.txt`); no data | the text files |
| wave radar of the ship | `ancillaryData/cruise_data_legC/wave_radar`: about every 3 min peak and mean period, direction, significant wave height, surface current | yes |
| bathymetry of the deep site, 25 m grid | `processed/HighRes_Bathy` (provisional data of the USGS, gaps filled with the 3 arc second grid) | `NESBA_bathy.mat`, ReadMe files, scripts, plots (not the netCDF source and the 3 arc second grids) |
| ship positions (1 min), wind, maps and tracks of the tows, loggers as mat files | `processed/shipPositions`, `windSpeed`, `Maps`, `TLoggers_HOBO` | yes |
| experiment log, summary tables, hardware diagrams, calibration | `documents` | yes |

- Not copied: the acoustic data (1.1 TB), the spectrograms. `Matlab/Data` is in `.gitignore`.
- From the ReadMe files: hydrophone 1 is "approximately 7.1 m" above the seafloor (code: 7.25 m), and the logger on the float is 5.8 m (+/- 0.2 m) above the logger of hydrophone 16.
- `documents/Source_Tow_Details_2022_Angle_of_Intromission_V3.pdf` describes other tows (50 m depth, sweeps), not the one used here.

### 38.2 Depth of the source

Whole tow from 2025Z to 2135Z: mean 120.07 m; slow changes between 116.8 and 122.9 m; after removing the mean over 61 s a standard deviation of 0.45 m; mean change within 5 s 0.27 m.

| file | sensor: mean | sensor: standard deviation within the file | acoustic estimate (range-independent model) | acoustic minus sensor |
|---|---|---|---|---|
| 2030Z | 120.51 m | 0.20 m | 124.26 m | +3.75 m |
| 2100Z | 120.62 m | 0.21 m | 121.87 m | +1.25 m |
| 2110Z | 119.65 m | 0.44 m | 114.90 m | -4.75 m |
| 2120Z | 118.80 m | 0.71 m | 111.05 m | -7.75 m |
| 2130Z | 119.84 m | 0.18 m | 118.84 m | -1.00 m |

- **The source was at 119 to 121 m in all files.** The source depths of 115 and 111 m that the range-independent model finds at 1.7 and 2.3 km are errors of the model, not the source (with coupled modes, slope, and profile: 120 and 114 m, Section 37.4).
- **The vertical motion of the source does not explain the cap.** Simulated snapshots (model, steady range from the GPS) with the measured depth: cap 0.98 to 0.99 (constant depth 0.995; twice the measured changes 0.95 to 0.98) against 0.66 to 0.72 in the data; repeatability from frame to frame 0.91 to 0.96 against 0.59 to 0.74. Pair by pair, the measured repeatability is not related to the change of the depth between the two frames (correlation -0.13 over 55 pairs).
- With the measured depth of each frame instead of one depth, the fit rises by 0.000 to 0.015 (most at 2110Z and 2120Z, where the depth varied most).
- Use: the sensor can replace the wide prior of the source depth (100 to 140 m). The offset between sensor and transducer is not known; at 2100Z the acoustic estimate is 1.25 m deeper than the sensor.

### 38.3 Swell

Wave radar from 2030Z to 2136Z: significant wave height 1.50 to 1.72 m (standard deviation of the surface 0.38 to 0.43 m), peak period 8.9 to 9.7 s, mean period 7.3 to 7.6 s, coming from 90 to 96 deg, i.e. along the track (the source is at 105 to 111 deg from the array from 2100Z on). Section 25 had assumed "a few decimetres" from the wind. A surface that moves by 0.41 m changes the phase of a path reflected at it under 15 deg by 0.44 rad at 503 Hz and 1.1 rad at 1253 Hz.

### 38.4 Bathymetry along the paths

| file | source from VLA1 | depth at the source | mean depth along the path | slope (straight-line fit) | deviation from the line |
|---|---|---|---|---|---|
| 2030Z | 982 m towards 273 deg | 205.7 m | 204.6 m | 0.3 m per km | up to 1.1 m |
| 2100Z | 1025 m towards 111 deg | 206.7 m | 205.2 m | 3.7 m per km | up to 1.2 m |
| 2110Z | 1674 m towards 108 deg | 208.3 m | 205.6 m | 2.7 m per km | up to 1.3 m |
| 2120Z | 2344 m towards 105 deg | 209.6 m | 206.0 m | 2.6 m per km | up to 1.5 m |
| 2130Z | 3036 m towards 105 deg | 211.0 m | 206.9 m | 2.7 m per km | up to 2.0 m |

- **Water depth at VLA1: 204.0 m** (202.9 to 205.2 m within 50 m). Three measurements now agree on 204 to 205 m (echosounder and loggers in Section 31.2). The joint inversion has 199.9 m (prior bound 205 m), the refit with the logger profile 202.8 m.
- The slopes assumed in Section 37.4 (2.0, 1.8, 2.4, 3.0 m per km) are close to these. The mean depths along the three longer paths (205.6, 206.0, 206.9 m) are the water depths that the refits with the range held at the GPS value asked for (206.3, 206.3, 205.5 m, Section 37.2).
- The two files at 1 km have different bathymetry: flat at 2030Z, 3.7 m per km at 2100Z. This may be why each loses 0.03 to 0.04 with the best environment of the other (Section 37.7).
- The ranges from the 1 min positions agree with those from the raw GPS within 0.7%.

### 38.5 Phases of the arrivals within a file

At 1 km the direct path, the path reflected at the seabed, and the path reflected at the surface are resolved at 503 and 653 Hz (Section 37.5). Single snapshots (0.66 s, every 0.33 s) were beamformed to the three angles (Hamming taper); phase of each pair of beams over the 60 s, quadratic trend removed. From the three pairs, the standard deviation of each arrival by itself follows if the three are independent. Model: simulated snapshots with a flat surface, steady range, and the measured source depth, processed in the same way. Figure: the phases against the direct arrival.

| file, tone | direct | seabed | surface | model: direct, seabed, surface | surface as a moving mirror |
|---|---|---|---|---|---|
| 2030Z, 503 Hz | 0.10 rad | 0.38 rad | 0.66 rad | 0, 0.06, 0.14 rad | 0.46 rad |
| 2100Z, 503 Hz | 0.16 rad | 0.23 rad | 0.28 rad | 0, 0.04, 0.09 rad | 0.44 rad |
| 2100Z, 653 Hz | 0.19 rad | 0.39 rad | 0.41 rad | 0, 0.04, 0.13 rad | 0.58 rad |

- **The arrivals change their phases against each other within seconds, several times more than the steady motion and the measured depth of the source give.** The direct arrival is the steadiest, also in strength (scintillation index at 503 Hz: 0.10 direct, 0.20 to 0.28 seabed, 0.25 to 0.63 surface).
- The arrival from the surface changes most, by about what the measured swell predicts for a moving mirror. (Section 40: the amount agrees, but the changes at 503 and 653 Hz are unrelated in time, which a moving mirror would not give; it is scattering.)
- The arrival from the seabed changes too (0.23 to 0.39 rad). A flat seabed and the measured motion of the source give 0.04 to 0.06 rad. This is not explained.
- At 2030Z and 653 Hz the phase of the surface arrival could not be followed (standard deviation 1.6 rad). At 803 Hz and above, steeper paths fold into the beams (hydrophone spacing of 3.75 m), and the three arrivals cannot be separated.

### 38.6 Fit without the arrival from the surface (503 Hz)

Data and replica projected onto the plane waves of a sector of the arrival angle; cap and fit within the sector, mean over the 12 frames; replica at the best position of each file.

| sector | 2030Z: cap, fit, fit over cap | 2100Z: cap, fit, fit over cap |
|---|---|---|
| all angles | 0.756, 0.437, 0.58 | 0.826, 0.523, 0.63 |
| direct and seabed (-12 to +8.5 deg) | 0.851, 0.715, 0.84 | 0.856, 0.692, 0.81 |
| surface (above +9.5 deg) | 0.737, 0.389, 0.53 | 0.858, 0.472, 0.55 |

- **At 503 Hz the model describes the direct and the seabed-reflected sound, including the phase between them, at 0.81 to 0.84 of what is attainable.** The mismatch is in the sound that comes from the surface.
- Limits: one tone. The sectors are subspaces of 9 and 7 dimensions that overlap, so the shares of the power in them are not reliable and are not given. At 653 Hz the sectors are no longer clean and show no difference (0.62 to 0.66 in both); above, no separation is possible.

### 38.7 What this changes

- **Withdrawn:** the motion of the source in depth as the cause of the changes within a frame (Section 38.2), and the conclusion of Section 37.1 that the changes arise at the source or the array. The cap that does not fall with range does not exclude the surface: the steep paths that touch it are also the ones that the seabed removes with range.
- **Most likely cause of the changes within a frame: the sea surface under a swell of 1.5 to 1.7 m that runs along the track.** (Section 40: as a rough surface that scatters, not as a mirror that moves; and a motion of the array is ruled out.) For it: the time scale of seconds (Section 19), the cap that falls with frequency, the surface arrival that changes most and by the predicted amount, and the mismatch at 503 Hz that sits in the sound from the surface. Not explained by it: the changes of the seabed arrival (Section 38.5); and roughness as a loss in KRAKEN does not raise the fit (Section 25.1). Not established.
- The model cannot predict sound reflected at a moving surface. What a static, flat-surface model can reach is therefore limited by the share of that sound, which is the ceiling of Section 34 seen from another side.
- **For the next inversion** (Section 33.6), proposed, not set up:
  1. Source depth: prior from the sensor (120.6 m at 2100Z plus an offset of about 1 m, a few metres wide) instead of 100 to 140 m.
  2. Water depth at VLA1: 204.0 m with a narrow prior; three measurements agree.
  3. Bathymetry along the path: measured, 3.7 m per km at 2100Z. It belongs in the forward model (coupled modes, Section 37.4) rather than in the unknowns.
  4. To examine: a likelihood that leaves out or down-weights the sound from the surface. The information on the seabed is in the direct and seabed-reflected arrivals, and at 503 Hz the model already fits them well. With this array the arrivals separate at the lowest tones only.

## 39. Hydrophone depths tied to the water depth of the model: does this cause problems? (2026-11-17)

Question of Florian Meyer: the model places the hydrophones at the water depth minus their heights above the seafloor (`getReceiverGeometrySBCEXP22.m`). The environment is not range independent, so the water depth of the fit is not the true one; does the tie then move the hydrophones to wrong depths, and could this explain what Section 38.5 left open (the seabed arrival that changes its phase)? Scratch scripts in `/var/tmp/<user>/tests2`: `depthCouplingTest.m`, `bathyCoupledTest.m` (logs `log_dc_*.txt`, `log_bc_*.txt`). No code of the repository was changed.

### 39.1 The changes of the seabed arrival do not come from the model

The phases of Section 38.5 are measured on the data alone (phase between beams of single snapshots over 60 s). The model enters only as a comparison. How the model places the hydrophones cannot produce them.

### 39.2 Array with its own depth, separate from the water depth

Range-independent model, logger profile, seven unknowns as before. In addition the array (hydrophones and loggers) can have an offset in depth relative to the tied position (positive: deeper). Local searches from several starts; fitted / held-out frames. Measured water depth at VLA1: 204.0 m (Section 38.4).

2100Z:

| case | logL | correlation | water depth | offset of the array | range shift against the GPS |
|---|---|---|---|---|---|
| as in the code (tied) | 313.7 | 0.474 / 0.466 | 202.84 m | 0 | -10.9 m |
| offset free in addition (5 starts) | 315.1 | 0.476 / 0.467 | 202.78 m | -0.11 m | -10.1 m |
| hydrophones at 204.0 m minus their heights, water depth free | 312.1 | 0.472 / 0.460 | 204.15 m | -0.15 m | +1.2 m |
| water depth 204.0 m, tied | 311.7 | 0.472 / 0.461 | 204.0 m | 0 | -1.5 m |
| water depth 204.0 m, offset free | 313.5 | 0.473 / 0.462 | 204.0 m | -0.21 m | +1.2 m |
| water depth 205.2 m (mean of the path), hydrophones at 204.0 m minus their heights | 302.0 | 0.459 / 0.445 | 205.2 m | -1.2 m | +12.1 m |

- **The tie is not a problem.** With its own offset the array ends within 0.1 to 0.3 m of the tied position from all five starts, and the fit gains 0.001. The hydrophones are where the model puts them relative to the seabed.
- **The suspicion about the water depth is right.** The data hardly distinguish a water depth of 202.8 m with the source 11 m short of the GPS range from the measured 204.0 m with the source on the GPS range (logL 313.7 against 311.7). Water depth and range trade off; 202.8 m is one point on that ridge, not a measurement of the water depth. The same holds for the 199.9 m of the joint inversion with XBT #11.
- With the water depth at 204.0 m the source is at the GPS range within 1.5 m and at 121.9 m depth (sensor: 120.6 m). Fixing the water depth costs 2 in the log-likelihood and removes this trade-off.
- The mean depth of the path as the water depth is worse (302.0), with the seabed running to its bounds.
- 2030Z: the searches end in different local maxima of the seabed (thin slow layer over a fast halfspace: 314.7; others 270 to 293), so the cases cannot be compared there. In all of them the offset stays between -0.6 m and 0.

### 39.3 Coupled modes through the measured bathymetry

Cells of 25 m fixed to the seabed, depth of each cell from the 25 m grid, one-way coupled modes (as Section 37.4), hydrophones at the measured local depth minus their heights, seabed of the best state; search over range shift, source depth, and tilt only. Correlation of all 12 frames (fitted / held out).

| seabed depth | 2100Z | at | 2030Z | at |
|---|---|---|---|---|
| flat, 202.8 m, hydrophones tied (as so far) | 0.470 (0.472 / 0.468) | -13.4 m, 121.5 m | 0.413 (0.419 / 0.408) | -4.0 m, 124.0 m |
| flat, 204.0 m | 0.466 (0.471 / 0.461) | -0.9 m, 122.0 m | 0.413 (0.419 / 0.407) | +8.5 m, 124.5 m |
| flat, mean of the path, hydrophones at 204.0 m minus heights | 0.422 (0.429 / 0.416) | +26.6 m, 124.5 m | 0.415 (0.422 / 0.408) | +16.0 m, 125.5 m |
| straight slope between array and source | 0.459 (0.465 / 0.453) | +19.1 m, 124.0 m | 0.413 (0.418 / 0.407) | +16.0 m, 125.5 m |
| measured depth of each cell | 0.472 (0.475 / 0.468) | -0.9 m, 122.0 m | 0.385 (0.394 / 0.377) | +11.0 m, 125.0 m |

- 2100Z: with the measured bathymetry and no free water depth the fit is the same as with the fitted flat seabed (0.472 against 0.470), and the source is on the GPS range (-0.9 m). The path is flat at about 204 m for the first 450 m from the array and 2 to 3 m deeper beyond; a straight slope describes this less well (0.459).
- 2030Z: the measured cells lower the fit (0.385 against 0.413). On this path the grid has bumps of 1 to 1.5 m over 100 to 300 m; the data set is provisional (its ReadMe mentions jitter), and whether these bumps are real was not examined.
- So the measured bathymetry does not raise the fit. It replaces the free water depth and its trade-off with the range at 2100Z.

### 39.4 Relief of the seabed and the phase of the seabed arrival

Idea: the source moves by 64 m in a file, so the reflection point moves over a seabed that is not flat. Simulated snapshots for the moving source through the measured cells, processed as the data in Section 38.5: the phase of the seabed arrival changes by 0.002 rad (constant source depth) and 0.04 to 0.06 rad (measured source depth), against 0.23 to 0.39 rad in the data. **The relief that the 25 m grid resolves does not explain the changes of the seabed arrival.** Relief finer than 25 m and scattering out of the vertical plane are not covered. The observation stays unexplained.

### 39.5 Consequence

For the next inversion: fix the water depth at VLA1 at the measured 204.0 m (or give it a narrow prior) and keep the hydrophones tied to it. This is point 2 of Section 38.7, now tested: it costs nothing in the fit at 2100Z and puts the source on the GPS range. A forward model with the bathymetry of each cell is not needed for the 2100Z file.

## 40. Could a vertical motion of the array explain the changes of the arrival phases? (2026-11-17)

Question of Florian Meyer: could the array move up and down in the water column, for example with internal waves, and so cause the changes of the seabed arrival of Section 38.5? Scratch script `heaveTest.m` (`/var/tmp/<user>/tests2`, log `log_heave.txt`); data only, processed as in Section 38.5. No code of the repository was changed.

An array that is dz deeper changes the phase of an arrival from the angle theta (positive: from above) by -k sin(theta) dz. Against the direct arrival (+3 deg), the seabed arrival (-6.5 deg) and the surface arrival (+15 deg) then move in opposite directions, in the ratio 1 to 1.2, and at all tones in proportion to the frequency.

| | 2030Z, 503 Hz | 2030Z, 653 Hz | 2100Z, 503 Hz | 2100Z, 653 Hz | vertical motion of the array |
|---|---|---|---|---|---|
| correlation of seabed-direct with surface-direct | +0.04 | -0.06 | +0.29 | +0.19 | -1 |
| motion needed for the seabed arrival | 1.05 m rms | 0.85 m rms | 0.78 m rms | 0.98 m rms | |

| the same series at 503 Hz and at 653 Hz | 2030Z | 2100Z | any change of geometry |
|---|---|---|---|
| vertical motion fitted to both arrivals: correlation between the tones | +0.07 | +0.04 | +1 |
| seabed-direct: correlation between the tones | 0.00 | +0.17 | +1 |
| surface-direct: correlation between the tones | +0.09 | +0.11 | +1 |

- **A vertical motion of the array is ruled out.** It would need about 1 m rms within seconds; the two series are not opposed but unrelated or weakly alike; and the motion fitted at 503 Hz is unrelated to the one fitted at 653 Hz.
- Mechanically it is not expected either: with the measured tilts (within 0.3 deg) the top of a taut mooring of 70 m moves vertically by less than 1 mm. Internal waves move the water past the array within minutes, not the array, and slow changes were removed with the trend.
- **The changes at 503 Hz and at 653 Hz are unrelated in time.** Any displacement (of the array, of the source, or of a surface that acts as a mirror) changes path lengths and would give the same series at both tones, in proportion to the frequency. The changes are therefore not a displacement. They depend on frequency within 150 Hz, which is what interference does: each of the three arrivals is itself the sum of several contributions whose relative phases change within seconds. This is scattering, at the moving sea surface for the surface arrival and probably at a seabed that is rough on scales below the 25 m grid for the seabed arrival, as the source moves. The second part is an interpretation; the roughness of the seabed is not measured.
- **Correction of Section 38.5 and 38.7:** the surface arrival changes by the amount that a mirror moving with the swell would give, but not in the way a mirror would (unrelated between the tones). The sea surface remains the likely cause for that arrival, as a rough surface that scatters, not as a mirror that moves up and down.
- Number of independent values in a series of 60 s: about 20 to 40, so a correlation is uncertain by about 0.2. The values are clearly not near +1 or -1.

## 41. Roughness of the sea surface and of the seafloor in the forward model (2026-11-17)

Question of Florian Meyer: can the roughness of the seabed and of the surface be modelled, as was done for the seabed in the other project? Scratch scripts in `/var/tmp/<user>/tests2`: `rt_modes.m` (KRAKEN with a roughness of the two interfaces), `roughnessTest.m`, `jointRoughnessTest.m` (logs `log_rough_*.txt`, `log_jr_*.txt`). No code of the repository was changed.

**What the other project does:** a first-order loss for each mode. A rough boundary scatters sound out of the coherent field; the loss grows with the third power of the vertical wavenumber of the mode. The rms roughness of the seabed is a sampled unknown (as its logarithm). There it raised the fit by 0.01 to 0.02 and traded off with the loss in the seabed.

**Here:** the same physics through KRAKEN (`SIGMA` of the sea surface and of the seafloor in the environment file; KRAKEN adds the loss to the imaginary part of the wavenumbers and evaluates it with the actual mode shapes at the interface). At 803 Hz, 0.4 m at the surface adds 0.1 to 2.9 dB/km from the middle to the steepest modes, 0.4 m at the seafloor up to 1.2 dB/km. The roughness of the surface is known from the wave radar (Section 38.3): 0.38 m rms at 2030Z, 0.41 m at 2100Z. Range-independent model, logger profile, seven unknowns, fitted / held-out frames, local searches.

### 41.1 Roughness as a loss, single files

| case | 2030Z: logL, correlation | 2100Z: logL, correlation |
|---|---|---|
| no roughness | 314.7, 0.470 / 0.484 | 313.7, 0.474 / 0.466 |
| surface as measured | 330.3, 0.485 / 0.502 | 309.2, 0.470 / 0.466 |
| surface as measured, seafloor free | 331.2, 0.486 / 0.503 (seafloor 0.28 m) | 309.2, 0.470 / 0.467 (0.04 m) |
| surface and seafloor free | 332.0, 0.487 / 0.503 (surface 0.34 m, seafloor 0.50 m) | 313.7, 0.474 / 0.466 (0.00 m, 0.02 m) |

- At 2030Z the measured roughness of the surface raises the fit by 16 in the log-likelihood (0.016 fitted, 0.018 held out), and left free it comes out at 0.34 m, close to the 0.38 m of the wave radar. The roughness of the seafloor adds 1 to 2 and is not determined.
- At 2100Z, started from its own best seabed, roughness does not help and the free values return to zero.
- The two files have different seabeds in these fits: 2030Z a thin slow layer over a hard halfspace (2 m, 1490 m/s over 1700 to 1810 m/s), 2100Z a 5 to 9 m layer of 1557 to 1573 m/s over 1596 m/s. A hard halfspace keeps steep modes, which the surface then has to remove; a soft halfspace removes them itself. **Roughness and the seabed trade off** (as in the other project).

### 41.2 The two files at 1 km with one seabed

One seabed, water depth, and tilt; range shift and source depth for each file. Two starts for the seabed.

| case | logL of both files | 2030Z | 2100Z | seabed |
|---|---|---|---|---|
| no roughness | 617.9 | 0.464 / 0.472 | 0.463 / 0.424 | 3.1 m, 1513 m/s over 1701 m/s |
| surface as measured | 639.6 | 0.473 / 0.485 | 0.479 / 0.450 | 2.6 m, 1523 m/s over 1718 m/s |
| surface as measured, seafloor free | 647.5 | 0.480 / 0.491 | 0.481 / 0.451 | 2.1 m, 1510 m/s over 1744 m/s; seafloor 0.71 m |
| second start (seabed of 2100Z): none / surface / surface and seafloor | 583.8 / 577.0 / 623.4 | | | 4 to 5 m, 1549 to 1563 m/s over 1604 m/s without seafloor roughness |

- **When both files have to share one seabed, roughness raises the fit:** by 22 with the measured surface and by 30 with a free seafloor roughness, and the held-out frames of both files improve (2030Z by 0.013 to 0.019, 2100Z by 0.026 to 0.027).
- The common seabed that wins is the thin slow layer over a hard halfspace (1700 to 1744 m/s), not the seabed of the inversions of the 2100Z file alone (1596 m/s). **Which seabed comes out depends on whether roughness is in the model and on whether one file or two are used.**
- The level stays at 0.45 to 0.49. Roughness as a loss does not close the gap to the cap.

### 41.3 The scattered sound as part of the model

The loss removes energy from the model; the scattered sound itself is not in it. Simplest extension: the energy that a mode loses to scattering stays in that mode with a random phase. The model of the cross-spectral matrix of a frame is then the coherent field plus a sum over the modes. Compared with the measured matrices at the best state without roughness.

| 2100Z | 503 Hz | 653 Hz | 803 Hz | 1003 Hz | 1253 Hz |
|---|---|---|---|---|---|
| measured cap | 0.83 | 0.74 | 0.70 | 0.67 | 0.58 |
| model, surface 0.41 m (measured) | 0.93 | 0.89 | 0.84 | 0.79 | 0.73 |
| model, surface 0.41 m and seafloor 0.5 m | 0.88 | 0.80 | 0.73 | 0.66 | 0.58 |

| 2030Z | 503 Hz | 653 Hz | 803 Hz | 1003 Hz | 1253 Hz |
|---|---|---|---|---|---|
| measured cap | 0.76 | 0.68 | 0.66 | 0.62 | 0.60 |
| model, surface 0.38 m (measured) | 0.88 | 0.84 | 0.80 | 0.72 | 0.70 |

- **The measured swell alone gives about half of the missing coherence, with the right trend in frequency and without a free value.** With 0.5 m at the seafloor in addition, the caps at 2100Z agree at the three upper tones; that value is not measured.
- Gaussian likelihood of the whole matrix (scale and a white floor fitted for each frame and tone; sum over the 30 fitted tone-frame pairs, per snapshot; refit of the seven unknowns):

| case | 2030Z: fitted / held out | 2100Z: fitted / held out |
|---|---|---|
| no roughness | 1058.8 / 1075.4 | 1055.5 / 1050.4 |
| surface as measured | 1097.1 / 1115.3 | 1052.4 / 1051.0 |
| surface as measured, seafloor free | 1098.3 / 1113.3 (0.58 m) | 1052.3 / 1050.5 (0.01 m) |
| surface and seafloor free | 1098.2 / 1114.5 (0.38 m, 0.57 m) | 1056.5 / 1052.7 (0.01 m, 0.17 m) |

- At 2030Z this model is clearly better than the present one (38 fitted, 40 held out, per snapshot), and the free roughness of the surface comes out at 0.38 m, the measured value. At 2100Z, from its own seabed, it is not better. The pattern is the same as in Section 41.1; a joint fit of the two files with this likelihood was not made.
- Limits: first-order loss; scattered energy kept in the mode that lost it (in the data it is spread over the arrival angles, Section 37.5); local searches.

### 41.4 Assessment

- Yes, roughness can be modelled, in the same way as in the other project, and for the surface with a measured value instead of an unknown.
- It matters more for the seabed estimate than for the level of the fit. With one file the seabed can absorb what roughness does; with two files it cannot, and roughness is then needed.
- Proposed (not implemented in the code of the repository): optional fields for the two roughness values in the scenario, passed to the environment file; surface from the wave radar, seafloor as an unknown with a wide prior; and the next inversion on the two files at 1 km together.

## 42. Range-dependent EOF run: complete file and evaluation (2026-11-17)

The run of Section 27 (`mainData14L1HRangeDependent.m`, started on 2026-11-15 at 23:31 PST) ended on 2026-11-17 at 20:58 PST with 20,000 samples, 150,848 s, no error samples. The complete file is on this Mac as `Matlab/Work-in-Progress/GI/resultsDataEOFRangeDependent_run20261115T2331_20000samples.mat` (25 MB; not committed). Evaluation with the scratch scripts `evaluateRangeDependent.m` and `evaluateCoupledAtMap.m` (`/var/tmp/<user>/evalRD`, logs `log_final.txt` and `log_final_coupled.txt`), burn-in 5,000 samples as in Section 32.

### 42.1 The chain changed its region after about 11,000 samples

Means over blocks of 1,000 samples at temperature 1:

| samples | log-likelihood | water depth | halfspace speed | third coefficient at the array | third coefficient of the difference | share with more than 0.4 m/s difference at 150 m |
|---|---|---|---|---|---|---|
| 1 to 10,000 (each block) | 300.4 to 301.5 | 201.5 to 202.4 m | 1585 to 1588 m/s | 1.2 to 1.4 | -0.27 to -0.13 | 0.15 to 0.26 |
| 10,001 to 11,000 | 302.8 | 202.5 m | 1610 m/s | 1.43 | 0.01 | 0.30 |
| 11,001 to 20,000 (each block) | 307.8 to 310.3 | 204.4 to 204.7 m | 1668 to 1683 m/s | 1.8 to 1.9 | 0.65 to 0.79 | 0.80 to 0.92 |

- The chain was stationary for 10,000 samples (the region evaluated in Section 32), then moved within about 1,000 samples to a second region that is higher by 7 to 9 in the log-likelihood, and stayed there. The run is therefore not converged as a whole: the second region was found once, late.
- In the second region three values lean against their bounds: the water depth (205 m; 56% of the samples above 204.5 m), the third coefficient at the array (bound 2; 55% above 1.8), and the third coefficient of the difference between the two ends (bound 1; 29% above 0.9).

### 42.2 Fit

| | logL of the fitted frames | correlation fitted / held out |
|---|---|---|
| MAP of the complete run (sample 18,083) | 316.6 | 0.4735 / 0.4440 |
| the same with the difference between the two ends set to zero | 214.6 | 0.3455 / 0.3305 |
| 60 posterior samples (samples 5,001 to 20,000) | | 0.4637 / 0.4442 |
| MAP of the first 10,000 samples (Section 32) | 308.1 | 0.467 / 0.458 |
| logger profile, no new unknown (Section 31.5) | 312.7 | 0.473 / 0.464 |

- In the second region the fitted frames gain and **the held-out frames lose** (0.444 against 0.458 in the first region). The gain is not carried by the data that were not fitted.
- Posterior of the complete run (not to be used as estimates, see below): range 1030 m (997 to 1049), source depth 123.9 m, water depth 203.6 m, top of the layer 1509 m/s (1465 to 1555), thickness 3.1 m, halfspace 1642 m/s (1579 to 1712).

### 42.3 The second region is an effect of the adiabatic approximation

The field of the code (adiabatic modes, two KRAKEN runs) against one-way coupled modes through a profile that changes linearly between the two ends (20 segments), for the MAP and 12 posterior samples:

| states | difference between the ends at 150 m | coupled against the field of the code, per tone | fit with the code, fitted / held out | fit with coupled modes |
|---|---|---|---|---|
| first region (6 samples) | -0.14 to +0.56 m/s | 0.97 to 1.00 | 0.459 to 0.464 / 0.446 to 0.459 | 0.458 to 0.465 / 0.444 to 0.460 |
| second region (6 samples) | -0.51 to -0.60 m/s | 0.99, 0.97, 0.94 to 0.96, 0.85 to 0.89, 0.77 to 0.84 | 0.460 to 0.472 / 0.428 to 0.448 | 0.410 to 0.443 / 0.383 to 0.416 |
| MAP | -0.58 m/s | 0.99, 0.95, 0.92, 0.86, 0.79 | 0.4735 / 0.4440 | 0.4294 / 0.4029 |

- In the first region the code and coupled modes agree (as Section 37.4, addition). **In the second region they do not: with coupled modes the MAP has 0.429 / 0.403 instead of 0.474 / 0.444, lower than every state of the first region.** The second region exists only in the approximate model. The sampler found a combination of differences for which the error of the approximation happens to resemble the data of the fitted frames.
- This corrects the addition to Section 37.4: the approximation does not only penalize larger differences, it can also reward them.
- **Result of the run:** samples 1 to 10,000 are a valid sample of the model with small differences; their evaluation is Section 32 (0.467 / 0.458; differences not resolved; no gain over the logger profile without new unknowns). Samples 11,001 to 20,000 and the MAP of the complete run are not to be used. A range-dependent profile needs coupled modes in the forward model before it is inverted for (open point 13).

## 43. Joint inversion of the two files at 1 km: set up, not started (2026-11-17)

Request of Florian Meyer: set up the joint inversion proposed in Section 41.4. The code is in the repository and tested on the server in the test copy (`/var/tmp/<user>/orcaTest/repo`); the inversion is **not started**.

### 43.1 Code

New:
- `mainData14L1HTwoFiles.m`: joint inversion of the 2100Z file (source to the east-southeast, leaving) and the 2030Z file (source to the west, approaching), six windows of each fitted (1, 3, ..., 11), six held out. Results file `resultsDataTwoFiles.mat` (intermediate file every 5,000 samples).
- `getLoggerTemperaturesSBCEXP22.m`: temperatures of the 17 loggers of VLA1 at the time of a file from the processed logger files, calibrated with CTD #28 (offsets of Section 31 as a table in the function), and their heights above the seafloor (0.2286 m below each hydrophone; the logger on the float 5.8 m above the top one, as documented in the experiment folder; the tests of Sections 31 to 42 used 6.03 m).
- `getLoggerProfileSBCEXP22.m`: profile of the water from the loggers and the reference cast for a given water depth (the hybrid profile of Section 31.5, so far only in scratch scripts).
- `getSourceRangesGPSSBCEXP22.m`: range of the source from the 1 min positions of the ship, the source where the ship was when it was the layback away in a straight line (Section 36.3).

Changed (all additions are optional; the other scripts give the same results as before):
- `writeKrakenEnvSBCEXP22.m`: optional input `roughness` (sea surface, seafloor; `SIGMA` of the first and second medium).
- `getModesSBCEXP22.m`: passes `scenario.roughness` to it; an error with ORCA if a roughness is not zero.
- `getPressuresFromStateSBCEXP22.m`: `scenario.files` (several files that share the environment: state entries of range and depth, range offsets of the windows, logger temperatures, and surface roughness of each file); `scenario.roughnessSeafloorIndex` (seafloor roughness as a state entry); `scenario.loggers` (profile from the loggers, moving with the water depth).

### 43.2 Model of the run

| | |
|---|---|
| state (17 entries) | the 14 of the earlier scripts (range and depth of 2100Z in entries 1 and 2), then `sourceRange2`, `sourceDepth2` (2030Z), `roughnessSeafloor` |
| unknowns (9) | range and source depth of each file, tilt, top speed of the layer, thickness, halfspace speed (bottom of the layer coupled to it), seafloor roughness |
| known | water depth 204.0 m (Section 38.4), densities and attenuations as before, surface roughness 0.415 m (2100Z) and 0.375 m (2030Z) from the wave radar |
| priors | ranges: GPS (layback 155 m), Gaussian with 100 m; source depths 116 to 128 m (sensor 120.6 and 120.5 m); tilt -3 to 3 deg; top speed 1450 to 1750 m/s; thickness 0.5 to 15 m; halfspace 1550 to 1900 m/s; seafloor roughness 0 to 1.5 m |
| water profile | loggers of the array at the time of each file, XBT #11 above them |
| sampler | as before: 10 temperatures, 20,000 samples, start at the best state of a local search |

Data that the script reads in addition to the earlier ones (in `Matlab/Data`, copied from the experiment folder, Section 38.1; also placed in the data folder on the server): `acoustic/RAVA01.22147203000.sio`, `processed/TLoggers_HOBO/HOBOs_matfiles`, `processed/shipPositions/SBCEXP22_shipGPS.mat`.

### 43.3 Checks (scratch script `testTwoFiles.m`, `/var/tmp/<user>/tests2`, log `log_twofiles.txt`)

- Source ranges against the raw GPS used in the tests: range rates 1.063 against 1.060 m/s (2100Z) and -1.069 against -1.077 m/s (2030Z), at most 0.4 m over a file. The range of the first window is 1034.5 m against 1027.3 m at 2100Z and 978.8 against 977.8 m at 2030Z; the raw files of the two hours come from two different receivers of the ship, the processed file from one. This is inside the uncertainty of the layback and is taken up by the unknown ranges.
- Logger profile against the scratch profile: at most 0.02 m/s.
- Forward model at the best state of the scratch fit of Section 41.2 (water depth 202.76 m, both roughness values): log-likelihood 648.58 against 647.51, correlation 0.4811 and 0.4805 against 0.4810 and 0.4795. The same state without roughness: 569.5.
- Local searches with the model of the run (water depth 204.0 m):

| start of the seabed | log-likelihood, fitted / held-out windows | 2100Z, fitted / held out | 2030Z, fitted / held out | state |
|---|---|---|---|---|
| thin slow layer over a fast halfspace | 638.6 / 617.3 | 0.482 / 0.449 | 0.468 / 0.478 | 3.15 m, 1495 m/s over 1804 m/s; seafloor roughness 0.77 m; tilt -0.04 deg; ranges -12.0 m and +10.5 m against the GPS; source depths 121.8 and 125.2 m |
| thicker layer over a slower halfspace | 620.3 / 602.8 | 0.482 / 0.456 | 0.451 / 0.459 | 1.5 m, 1493 m/s over 1657 m/s; 0.91 m; ranges -9.7 m and +9.8 m; 122.0 and 125.0 m |

- The first state is the start of the run (`firstSampleUnknowns`).
- **With the measured water depth the two files agree on the layback.** The source is 12.0 m closer than the GPS range at 2100Z (leaving) and 10.5 m farther at 2030Z (approaching): both mean a layback of about 166 m for this GPS antenna. With the water depth free (202.76 m, Section 41.2) the two files imply 184 m and 151 m. Fixing the water depth costs 10 in the log-likelihood (638.6 against 648.6) and makes the geometry of the two files consistent.
- Short run of the complete script (60 samples, 2 instead of 45 acceptances per unknown in the initialization): pool of 10 workers, no errors or error samples; first sample 638.1; the water depth stays at 204.0 m, the coupling holds, the known values are unchanged; the results file with the sensitivity of both files is written. Sampling took 6.9 s per sample with the server at a load of 12.
- Not run on this MacBook (no MATLAB job was started here).

### 43.4 To start it

On the server the clone still has the code of the last run. To do: copy the changed and new files of `Matlab/Work-in-Progress/GI` to the clone (the data are in place), then start `mainData14L1HTwoFiles` as the earlier runs (Section 23). Expected (estimates): initialization 2 to 3 h, then 28 to 38 h for 20,000 samples, depending on the other jobs on the server.

Open:
- `checkHeldOutWindows.m` and `showResultsData.m` are for one file. The evaluation of this run needs a version for two files (the test script above has the calculation).
- The start and the two regions of the seabed come from local searches. Whether the sampler moves between the regions will be seen in the run.

## 44. Joint inversion of the two files started on the server (2026-11-18)

Florian Meyer asked to start the inversion of Section 43.

- Before the start: no job of this project on the server; three jobs of the other project of the same account were running (started 17:40 PST, each with its own MATLAB preferences folder; load 18). They were not touched.
- Code: the six new and six changed files of `Matlab/Work-in-Progress/GI` (Section 43.1 and the uncommitted files of Sections 27 and 30) were copied to the clone `/var/tmp/<user>/GI-SBCEX22`; checksums equal to the local files. The six replaced files are kept in `/var/tmp/<user>/backup-20261118T2113`. The clone is still at commit `f0957d7` plus uncommitted files. The data were already in place (Section 43.2).
- Start: 2026-11-18, 21:14 PST, as the earlier runs:

```
mkdir -p /var/tmp/<user>/runs/twoFiles
cd /var/tmp/<user>/runs/twoFiles
MATLAB_PREFDIR=/var/tmp/<user>/matlab-prefdir setsid nohup nice -n 5 matlab -batch "addpath('/var/tmp/<user>/GI-SBCEX22/Matlab/Work-in-Progress/GI'); mainData14L1HTwoFiles" > /var/tmp/<user>/inversionTwoFilesLog.txt 2>&1 < /dev/null &
```

- Process 3372314 (`/var/tmp/<user>/inversionTwoFiles.pid`; a first entry in that file was the process of the remote shell and was corrected), log `/var/tmp/<user>/inversionTwoFilesLog.txt`, run folder `/var/tmp/<user>/runs/twoFiles`. **The result files are written into the run folder:** `resultsDataTwoFilesTmp.mat` every 5,000 samples and `resultsDataTwoFiles.mat` at the end.
- Check at 21:18 PST: pool of 10 workers; the initialization runs at the starting state for all temperatures; no errors, warnings, or error samples.
- Expected (estimates): initialization until about midnight; then 6 to 7 s per sample with the present load, i.e. the first intermediate file in the morning of 2026-11-19 and the end between the morning and the afternoon of 2026-11-20 (PST).
- When it has ended: copy `resultsDataTwoFiles.mat` to this Mac as `resultsDataTwoFiles_run20261118T2114_20000samples.mat` (a job on this Mac does this if the connection holds) and evaluate it for two files (held-out windows of both files, both regions of the seabed, Section 43.4).

### 44.1 The run is range independent; check against coupled modes at its starting state

Question of Florian Meyer before the start: does the run use coupled or adiabatic modes? Neither: one KRAKEN run for each file with a flat seabed at 204.0 m and one profile; the adiabatic branch of `getPressuresFromStateSBCEXP22.m` is only used by the script with EOF differences, and coupled modes are only in scratch scripts. Section 39.3 had compared the flat seabed with coupled modes through the measured bathymetry for the earlier seabed (halfspace 1596 m/s). The same comparison at the starting state of this run (3.15 m of 1495 m/s over 1804 m/s, roughness 0.77 m at the seafloor and the measured value at the surface; scratch script `bathyCoupledTest2.m`, logs `log_bc2_*.txt`; search over range, source depth, and tilt; all 12 windows, fitted / held out):

| seabed depth | 2100Z | 2030Z |
|---|---|---|
| flat, 204.0 m (the model of the run) | 0.463 (0.476 / 0.449) | 0.471 (0.465 / 0.477) |
| straight slope between array and source | 0.448 (0.464 / 0.431) | 0.464 (0.461 / 0.468) |
| measured depth of each 25 m cell, coupled modes | 0.457 (0.463 / 0.452) | 0.387 (0.397 / 0.378) |

- At 2100Z the measured bathymetry with coupled modes fits as the flat seabed does (0.457 against 0.463, same position within 2.5 m). At 2030Z it is clearly worse (0.387 against 0.471), as with the earlier seabed; the bumps of the provisional grid on that path are the likely reason (Section 39.3).
- So for the seabed that the run starts from, the range-independent model is not worse than coupled modes through the bathymetry that is available. The check was announced one message earlier as running; it was only started after the inversion.

## 45. `showResultsData.m`: range-dependent run and a figure on the EOFs (2026-11-18)

Request of Florian Meyer: show the results of the previous run (the range-dependent EOF run, Section 42) with `showResultsData.m`, and add one representative figure on the EOFs.

- `resultsFile` is now `resultsDataEOFRangeDependent_run20261115T2331_20000samples` (added to the list of results files in the script).
- New setting `lastSample` (last sample that is used; `inf`: all). It is 10,000 for this run, because the chain sits in a region that coupled modes do not confirm from about sample 11,000 on (Section 42.3). Estimates, marginals, profiles, and the fit use samples 5,001 to 10,000. The figure with the sample traces still shows all samples, with red lines at the first and the last sample used; its labels are now horizontal.
- New figure "EOFs of the sound speed of the water" (results of `mainData14L1HRangeDependent.m` only), three panels: the 18 casts from which the EOFs are built with the measured profile and the estimated profile at the array; the three EOFs over depth with their share of the variance of the casts (69%, 11%, 8%); the contribution of each EOF to the estimated profile at the array (EOF times the median of its coefficient) and their sum with its 95% interval.
- New table in the output: for each EOF the share of the variance, its largest value and the depth of it, and the estimated coefficients at the array and of the difference between the two ends.
- Tested on the server without a display (scratch wrapper that writes the figures to files). The numbers agree with Section 32: MAP 308.1, correlation 0.467 at the MAP, cap 0.703. Not run on this MacBook.
- Figures of this run, written by that test, in `GI/Results`: `SBCEX22_VLA1_2100Z_range_dependent_inversion_marginal_posteriors.png`, `..._seabed_sound_speed.png`, `..._water_sound_speed.png`, `..._EOFs.png`, `..._samples.png`.
- What the EOF figure shows: the first EOF (6 m/s at 23 m) is the strength of the cold layer at 20 to 40 m; the inversion uses mostly EOFs 2 and 3 (coefficients 1.4 and 1.4, both leaning against the bound of 2) and makes the water at 20 m about 6 m/s slower than XBT #11. All of this is above 100 m. Below 100 m, where the array and the source are and where the loggers measure, the EOFs change the profile by less than 1 m/s and in the direction opposite to the loggers (Section 32).
- The script cannot show the results of `mainData14L1HTwoFiles.m` yet (two files; open in Section 43.4). Done on 2026-11-19, Section 47.

## 46. Joint inversion of the two files: status on 2026-11-19 at 14:10 PST

Florian Meyer asked for the status of the run of Section 44. Read from the log on the server; nothing was changed or started.

- Running (process 3372314, 16 h 56 min), no errors or warnings in the log. Sample 7,129 of 20,000.
- The initialization took about 6 h, until about 03:20 PST (estimated from the time of the intermediate file and the speed); the estimate of Section 44 was about 3 h.
- Speed: 5.5 s per sample (sample 5,000 at 10:56 PST, sample 7,122 at 14:10 PST), server load 12. **Expected end (estimate): 2026-11-20, about 10:00 PST.**
- `resultsDataTwoFilesTmp.mat` with the first 5,000 samples was written at 10:56 PST. The job on this Mac that copies the final file is still waiting.
- Log-likelihood of the chain at temperature 1: mean 634.0 to 634.2 in each block of 1,000 samples, largest value 638.5 (the local search of Section 43.4 found 638.6). No drift and no jump to another region so far (the range-dependent run jumped at about sample 10,800, Section 42).
- Swaps between temperatures: 29% of the proposals accepted (20,710 of 71,300); 21% of those with the chain at temperature 1.

Chain at temperature 1, samples 1,001 to 7,129, read from the log. This is a first look, not the evaluation (no held-out frames, no check of convergence):

| unknown | mean | standard deviation | smallest, largest | prior |
|---|---|---|---|---|
| source range, 2100Z | 1022.5 m | 0.9 m | 1019.3, 1025.9 | GPS range, Gaussian with 100 m |
| source range, 2030Z | 989.3 m | 0.9 m | 986.0, 992.5 | GPS range, Gaussian with 100 m |
| source depth, 2100Z | 121.82 m | 0.09 m | 121.53, 122.14 | 116 to 128 m (sensor 120.6 m) |
| source depth, 2030Z | 125.14 m | 0.09 m | 124.85, 125.45 | 116 to 128 m (sensor 120.5 m) |
| tilt | -0.04 deg | 0.03 deg | -0.13, 0.04 | -3 to 3 deg |
| speed at the top of the sediment | 1497 m/s | 7 m/s | 1471, 1520 | 1450 to 1750 m/s |
| thickness of the layer | 3.6 m | 0.6 m | 1.6, 6.0 | 0.5 to 15 m |
| speed of the halfspace | 1833 m/s | 40 m/s | 1701, 1900 | 1550 to 1900 m/s |
| roughness of the seafloor | 0.75 m | 0.12 m | 0.02, 1.13 | 0 to 1.5 m |

- The chain stays in the region of the starting state (Section 43.4: 3.15 m, 1495 m/s over 1804 m/s, roughness 0.77 m, source depths 121.8 and 125.2 m).
- **The speed of the halfspace reaches its upper bound of 1900 m/s.** The data bound it from below only (no sample below 1700 m/s). To look at in the evaluation: whether the histogram piles up at the bound, as the EOF coefficients did in the range-dependent run.
- The estimated source depth is 4.6 m deeper than the sensor value at 2030Z and 1.2 m deeper at 2100Z, as in the fits of Section 41; both intervals are narrow (0.09 m) and exclude the sensor values.

### 46.1 Correlation coefficients of the MAP sample of the intermediate file

Florian Meyer asked for the mean correlation coefficient of the MAP sample. Scratch script `twoFilesMapFit.m` (`/var/tmp/<user>/tests2`, log `log_twoFilesMapFit.txt`): setup part of the script of the run, a copy of `resultsDataTwoFilesTmp.mat` (samples 1 to 5,000), forward model with the scenario stored in that file. The run was not touched.

- MAP sample: sample 2,577, log-likelihood 638.51 (stored value reproduced), also the sample with the largest log-likelihood. State: ranges 1022.65 m and 989.65 m (-11.9 m and +10.9 m against the GPS), source depths 121.83 m and 125.15 m, tilt -0.05 deg, layer 3.87 m with 1495 m/s over 1868 m/s, seafloor roughness 0.80 m.
- Mean correlation coefficient (5 tones, 6 frames per file):

| | fitted frames | cap | held-out frames | cap |
|---|---|---|---|---|
| both files | 0.475 | 0.686 | 0.464 | 0.680 |
| 2100Z | 0.482 | 0.703 | 0.449 | 0.701 |
| 2030Z | 0.468 | 0.669 | 0.478 | 0.659 |

- By tone, fitted frames (503, 653, 803, 1003, 1253 Hz): 2100Z 0.594, 0.515, 0.498, 0.436, 0.366 (caps 0.814, 0.745, 0.718, 0.680, 0.559); 2030Z 0.552, 0.504, 0.507, 0.417, 0.361 (caps 0.758, 0.682, 0.676, 0.627, 0.601).
- Log-likelihood of the held-out frames 617.5. The mean of samples 1,001 to 5,000 gives the same values (0.475 fitted, 0.464 held out).
- The sampling has not raised the fit above that of the starting state (Section 43.3: 0.482 / 0.449 and 0.468 / 0.478). The MAP sample reaches 69% of the cap in the fitted and 68% in the held-out frames.

### 46.2 MAP sample against the MAP estimates of the earlier inversions

Florian Meyer asked whether the MAP is better than in the earlier inversions. The earlier runs used the 2100Z file only, with the same six fitted frames and five tones, so the comparison is made on that file. Part of the 2100Z file in the log-likelihood of the MAP sample of Section 46.1: 325.3 (fitted frames) and 295.7 (held-out frames); 2030Z: 313.3 and 321.8.

| 2100Z file | log-likelihood, fitted frames | correlation, fitted | correlation, held out |
|---|---|---|---|
| first run, one frame (Section 13.3) | | 0.482 on its frame | 0.420 |
| joint run of six frames (Section 13.6) | 296.5 | 0.455 | 0.448 |
| range-dependent EOF run, MAP of samples 1 to 10,000 (Section 32) | 308.1 | 0.467 | 0.458 |
| logger profile, local search, no inversion (Section 31.5) | 312.7 | 0.473 | 0.464 |
| two-file run, MAP of samples 1 to 5,000 | 325.3 | 0.482 | 0.449 |

By tone at 2100Z (503, 653, 803, 1003, 1253 Hz), two-file MAP against joint run: fitted 0.594, 0.515, 0.498, 0.436, 0.366 against 0.492, 0.464, 0.484, 0.455, 0.378; held out 0.581, 0.460, 0.427, 0.387, 0.393 against 0.528, 0.453, 0.448, 0.423, 0.390.

- **Fitted frames: yes.** Highest value of all runs (+29 in the log-likelihood and +0.027 against the joint run, +17 and +0.015 against the EOF run), although this run has less freedom for this file (measured water depth and profile, one seabed for two files). The gain is at 503 and 653 Hz; 1003 and 1253 Hz are slightly lower.
- **Held-out frames of 2100Z: no.** 0.449, as in the joint run (0.448) and below the EOF run (0.458) and the logger profile (0.464). 503 Hz is higher (+0.05), 803 and 1003 Hz are lower (-0.02 to -0.04). The difference between fitted and held-out frames at 2100Z has grown from 0.007 to 0.033.
- **Second file: yes.** The same environment fits the 2030Z file at 0.468 / 0.478 (fitted / held out). The environment of the joint run gave 0.397 on that file in MFP (Section 18), a common seabed without roughness 583.8 to 617.9 in the log-likelihood of both files (Section 41.2) against 638.5 now.
- Mean over both files on the held-out frames: 0.464, the value of the best single-file fit.
- **The gap to the cap is unchanged** (0.475 of 0.686). The seabed differs strongly from the earlier estimates (3.9 m with 1495 m/s over 1868 m/s against 3.5 m with 1549 m/s over 1588 m/s in the joint run), as noted in Section 41.2.

## 47. `showResultsData.m` and `checkHeldOutWindows.m` for results with two files (2026-11-19)

Florian Meyer decided to wait for the end of the run. Prepared in the meantime, so that the final file can be evaluated when it arrives (to do of Sections 43.4 and 44). Not committed.

- `showResultsData.m`:
  - Results with `scenario.files` (`mainData14L1HTwoFiles.m`): the data matrices of all files are loaded (all windows of the first file first, as in the inversion); the table of the correlation coefficients is printed for each file and as a mean over the files; new table "source range of the reference window minus its GPS range" for each file (MAP, median, 95% interval).
  - New setting `isZoomMarginals` (default `false`: the axis of each marginal and of each sample trace is the prior interval, as before; `true`: the range of the samples, with the prior interval in the axis label). Needed for this run: the posteriors of the ranges, the source depths, and the tilt are 50 to 500 times narrower than their priors and would fill one bin.
  - The new file name is in the list of results files (use `lastSample = inf` and `isZoomMarginals = true`). `resultsFile` still names the range-dependent run; it has to be changed when the file is there.
- `checkHeldOutWindows.m`: for results with `scenario.files` all 12 windows of each file are evaluated, with the GPS ranges stored in the results file (`scenario.files(f).sourceRangesGPSFile`); tables and means for each file and for all files, one panel per file in the figure. For results with one file the GPS ranges are computed as before.
- Tests on the server (test copy of the code, scratch wrapper `runShow.sh` / `runScript.m` in `/var/tmp/<user>/showTest`, logs `log_showTwo.txt`, `log_heldTwo.txt`, `log_showEOF.txt`, `log_heldJoint.txt`; not run on this MacBook):
  - Intermediate file of the two-file run (burn-in 1,000 for the test): both scripts run; the numbers are those of the scratch evaluation of Section 46.1 (638.51; 0.482 / 0.449 and 0.468 / 0.478; mean log-likelihood per window 54.2 / 49.3 and 52.2 / 53.6).
  - Earlier results unchanged: range-dependent run 308.14 and 0.467 (`showResultsData.m`); joint run 0.455 / 0.448 and 49.4 / 48.7 (`checkHeldOutWindows.m`).
  - A first attempt ran the four tests at the same time in one folder (the wrapper used `run`, which changes to the folder of the script); two of them failed because they shared their KRAKEN files. The wrapper now stays in its own folder. The scripts were not the cause.
- First look at the figures of the intermediate file (samples 1,001 to 5,000; preliminary):
  - Traces stationary and well mixed for all nine unknowns.
  - The marginals of the ranges, source depths, tilt, top speed, thickness, and roughness are single peaks inside their priors. **The marginal of the halfspace speed rises from 1700 m/s to a plateau from about 1800 m/s on and is cut by the bound of 1900 m/s.**
  - Seabed: the speed is well determined in the first 3 m (median and 95% interval: 1497 (1484 to 1510) m/s at the seafloor, 1592 (1581 to 1605) at 1 m, 1688 (1660 to 1716) at 2 m, 1780 (1733 to 1819) at 3 m), a gradient of about 95 m/s per m. Where the gradient ends is not determined: thickness and halfspace speed are correlated with 0.85, and the speed below is anywhere from 1750 to 1900 m/s.
  - Posterior samples (20): 0.473 (0.001) fitted and 0.462 (0.001) held out, mean over both files.

## 48. Server reached through the jump host of the university; status of the run on 2026-11-19 at 19:20 PST

- **Access.** Florian Meyer got access to the jump host of the university and made it the standard way to the compute server; the VPN is no longer needed. This Mac has the two entries for it in its SSH configuration (jump host, and the server through the jump host), so `ssh meyer01 '<command>'` and `scp` / `rsync` with the host name `meyer01` work without the VPN (verified). Commands in the earlier sections that name the server directly still need the VPN. The data server of the experiment can also be reached from the jump host (port check only; its login with a second factor is unchanged).
- This Mac restarted at about 15:30 PST. The run on the server is not affected. The job on this Mac that copies the final file was started again and now uses the new route.
- **Status of the run (Section 44) at 19:20 PST:** running, no errors or warnings, sample 10,523 of 20,000; intermediate file with 10,000 samples written at 18:33 PST. Speed 5.5 s per sample; **expected end (estimate) on 2026-11-20 at about 09:45 PST.** Log-likelihood of the chain at temperature 1: mean 634.0 to 634.2 in each of the eleven blocks of 1,000 samples, largest value 638.5; no drift and no jump.

## 49. Why the two-file inversion is slower than the inversions of the other project (2026-11-19)

Question of Florian Meyer. Numbers of the other project from its scripts and its work log (read only); timing of this project measured on the server with a scratch script (`timingTwoFiles.m`, `/var/tmp/<user>/tests2`, log `log_timingTwoFiles.txt`; MAP sample of Section 46.1, one thread, server load 11, the run not touched).

| | this run (two files) | other project, main scripts | other project, runs of November 2026 |
|---|---|---|---|
| time per sample | 5.5 s | 1.2 to 1.7 s (0.58 to 0.87 samples per s) | about 4.2 s (noted on 2026-11-14) |
| unknowns (one proposal each per sample) | 9 | 12 | 16 (about 13 model evaluations) |
| mode computations per proposal | 2 (one per file) | 1 | 1 |
| mode computations per sample and temperature | 18 | 12 | about 13 |
| tones | 503 to 1253 Hz, 204 m of water | 49 to 388 Hz, 128 m of water | |
| modes per tone | 82, 107, 131, 164, 205 (689 in all) | 8 to 56 (185 in all), at most 50 used | |
| temperatures | 10 | 11 to 12 | 10 |

Where the time of one KRAKEN run of this project goes (0.22 s in the test, about 0.30 s inside the run with ten workers at the same time): `kraken.exe` 0.16 s, of which 0.15 s is its own computing time (three meshes per tone; 0.010 s at 503 Hz up to 0.059 s at 1253 Hz); reading the modes 0.04 s; writing the environment file 0.004 s; the rest of the forward model 0.02 s. Starting a program from MATLAB costs 0.003 s and is not the reason. A stored example of the other project reports 0.0003 to 0.006 s per tone and mesh.

- **Two mode computations per proposal.** Each file has its own water profile, source depth, and surface roughness, and both files are computed again for every proposal, also for a proposal that concerns one file only.
- **Each mode computation is heavier.** The tones are 3 to 10 times higher and the water is deeper: about four times as many modes and a finer depth mesh; the computing time of KRAKEN is about five times that of the example of the other project.
- Fewer unknowns work in the other direction (9 against 12).
- Against the runs of the other project of November 2026 (16 unknowns) the speed is about the same.
- The server is shared (load 11 to 12 during the run); an idle server gave 0.17 s per KRAKEN run (Section 6).

Not done, possible for a next run (the running one cannot be changed):

- A proposal of a source range needs no mode computation (the range enters only the phase of each mode), and a proposal of the range or source depth of one file needs the modes of that file only. Keeping the modes of the last accepted state of each file reduces 18 mode computations per sample to 12.
- With the mode shapes on a depth grid around the source and the array and interpolation, proposals of the source depths and of the tilt need no mode computation either: 8 per sample. The interpolation would have to be checked against the exact depths first.
- **In-memory KRAKEN (found on 2026-11-19 at the request of Florian Meyer; not built for the server, not tested).** Outside the repository, in the folder `Model-Wrappers/Kraken` next to it, there is a KRAKEN that is called from MATLAB as a MEX function (`mkrak`), without environment, mode, or print files: subfolder `matlab.kraken.inmem.multifreq.mac` (source, a Makefile for macOS and one for Linux, a built file for Apple silicon only; a frequency vector is looped inside the function) and subfolder `matlab.kraken.parallel.mac` (a MATLAB wrapper that sends one frequency to each worker of a pool). Its interface takes the media with their rms roughness, the halfspace, lists of source and receiver depths, and returns the complex wavenumbers, so it covers what `getModesSBCEXP22.m` needs. What it can save here: the 0.06 s per run outside KRAKEN's own computing (about a quarter); the 0.15 s of computing stay unless the tones are computed in parallel, and the workers of the run are already used by the ten temperatures. The server has gfortran and MATLAB R2022a, so it can be built there.

## 50. Flag for the propagation model: `kraken_env`, `kraken_mex`, `orca` (2026-11-19)

Request of Florian Meyer: the inversion code gets a flag that switches between `kraken_env`, `kraken_mex`, and `orca`, where `kraken_mex` is the in-memory KRAKEN of Section 49; both KRAKEN versions may be in the repository, ORCA stays in `.gitignore`. Not committed.

### 50.1 Changes

- **Flag:** `scenario.model` in every main script of `Matlab/Work-in-Progress/GI` (`main14L1H.m`, `mainData14L1H.m`, `mainData14L1HContinuous.m`, `mainData14L1HJoint.m`, `mainData14L1HRangeDependent.m`, `mainData14L1HTwoFiles.m`); it was `'kraken_env'` in all of them at first and is `'kraken_mex'` since the same day (Section 50.5). The three older scripts had no flag.
  - `'kraken_env'`: `kraken.exe` with an environment file and a mode file, as before. Also used if the field does not exist and for `'Kraken'`, the name stored in the results files written so far.
  - `'kraken_mex'`: the same solver as a MEX function, without files (new).
  - `'orca'`: ORCA as before (was `'Orca'`; the names are not case sensitive).
- `getModesSBCEXP22.m`: reads the flag (an unknown name is an error with the identifier `SBCEX:krakenUnavailable`) and calls the new function for `'kraken_mex'`. The path with `kraken.exe` is unchanged: the stored log-likelihoods of the two-file run are reproduced exactly.
- `getModesKrakenMexSBCEXP22.m` (new): builds the arrays for `mkrak` from the same quantities that `writeKrakenEnvSBCEXP22.m` writes (profile of the water, sediment layer, halfspace, roughness of the sea surface and of the seafloor, phase speeds up to the speed of the halfspace, 20 km, dB/(m kHz)) and returns the modes in the form of the other two paths. A setup problem (no MEX file for the platform) has the identifier `SBCEX:krakenUnavailable`, a call that KRAKEN does not complete `SBCEX:krakenFailed` (a failed proposal for `getNextSample.m`).
- **`Matlab/KrakenMex` (new, 40 files, 1.1 MB):** source of the MEX function (copy of the folder found in Section 49), `LICENSE` (GNU GPL, version 3, the licence of KRAKEN), `README.md` (interface, build, changes, checks), `Makefile.macos`, `Makefile.linux`, and the MEX files `mkrak.mexmaca64` (Apple silicon) and `mkrak.mexa64` (Linux). Changes to the copied source: the print output of the solver is discarded (it went to a file `fort.6` that grows with every call); the MEX file stays loaded until MATLAB ends (`mexLock`; without it MATLAB crashed with a segmentation violation when it quit on the MacBook after the function had been used); Unix line endings.
- `ReferenceCode/bin/glnxa64/kraken.exe` (new in the working copy): the Linux `kraken.exe` that the runs on the server use (same checksum), so that `'kraken_env'` works on Linux from the repository. It needs `libgfortran` on the computer.
- `.gitignore`: files written by a build in `Matlab/KrakenMex` (`*.o`, `*.mod`, `*.a`, `*.log`, `fort.6`). `Matlab/Orca/` stays ignored.
- Not changed: `MFP.m` has its own call of `kraken.exe` (`computeModesMFP.m`).

### 50.2 Build

- Linux (server, gfortran 11.5, MATLAB R2022a): the build file of the copied folder used `-O2`; with it the MEX version was **slower** than `kraken.exe` (0.53 s against 0.42 s for a forward model of both files). The instruction set decides: `-O3 -ffast-math -funroll-all-loops -fomit-frame-pointer` alone 0.51 s, with `-march=x86-64-v3` (AVX2, FMA) 0.30 s, with `-march=native` 0.31 s. The build file now uses x86-64-v3, which runs on processors since about 2013. `kraken.exe` was built with the flags of the toolbox (`-march=native -O3 -ffast-math`).
- macOS (Apple silicon, gfortran 16.2 of Homebrew, MATLAB R2026b): the Fortran runtime is linked into the MEX file, so it needs no library of the compiler on the Mac that uses it.

### 50.3 Checks

On the server, test copy of the code, scratch scripts `compareKrakenVersions.m`, `compareLogLikelihoods.m`, `timeKrakenMex.m` (`/var/tmp/<user>/tests2`). The running inversion and its clone were not touched.

| | `kraken_mex` against `kraken_env` |
|---|---|
| number of modes, MAP sample of the two-file run | equal at all tones (82, 107, 131, 164, 205) |
| real part of the wavenumbers | equal to 1.3 parts in a million or better |
| imaginary part of the wavenumbers | within 1.7e-6 1/m |
| correlation of the two fields at the array, 41 states of the two-file run (roughness; MAP, posterior, hotter chains) | 0.9999987 or higher |
| the same, 41 states of the joint run (no roughness, free water depth) | 0.9999986 or higher |
| log-likelihood, 21 states of the two-file run | mean difference -0.007, standard deviation 0.012, largest 0.03 (MAP sample: 638.494 against 638.506) |
| time for a forward model, two-file run (two mode computations) | 0.30 s against 0.41 s (1.36 times faster) |
| time for a forward model, joint run (one mode computation) | 0.08 s against 0.13 s (1.6 times faster) |
| complete script `mainData14L1HTwoFiles.m`, 40 samples, pool of ten workers, server load about 20 | 3.6 s against 5.0 s per sample (1.38 times faster); whole run with initialization and sensitivity 661 s against 895 s |
| files written | none (no `fort.6`) |
| halfspace slower than the water (no modes) | `SBCEX:krakenFailed`; the next call works. `kraken_env` fails here with a size error of MATLAB |

- The differences come from the environment file, which holds the values with a few decimals (e.g. the seafloor roughness 0.801 instead of 0.80111 m, the phase speed limit in cm/s), from the mode file (wavenumbers in single precision), and from the depth mesh (20 points per wavelength in both, derived from the highest tone in the MEX function and from the first tone in the environment file).
- The two runs of the complete script (temporary copies with 2 acceptances per unknown in the initialization and 3 values in the sensitivity): no errors with either version; first sample 638.130 (`kraken_env`) and 638.129 (`kraken_mex`); the same 452 steps in the initialization at temperature 1; the results file with the sensitivity is written; no other file is left in the run folder. The chains separate after a few samples, because a difference of 0.01 in the log-likelihood now and then decides a proposal differently.
- ORCA after the change: `'orca'` and the old name `'Orca'` give the same field (correlation with the KRAKEN field 0.94 to 0.98 per tone, as in Section 29); roughness with ORCA is still refused (`SBCEX:orcaUnavailable`).
- `clear mex` leaves the MEX function loaded, and the next call gives the same field; MATLAB ends with exit code 0 on Linux.
- MacBook (two MATLAB batch runs of about a minute each, joint run, with and without roughness): correlation of the fields 0.9999992 or higher, 0.10 s against 0.15 s (1.5 times faster), no files, MATLAB ends without a crash (the first of the two runs, before `mexLock`, ended with the segmentation violation after the test had finished; its crash report in the home folder was removed).

### 50.4 Use and open points

- The clone on the server needs the new and changed files (`Matlab/KrakenMex`, `getModesKrakenMexSBCEXP22.m`, `getModesSBCEXP22.m`, the main scripts); they were **not** copied there, because the two-file run (Section 44) is still using that clone. To do before the next run on the server.
- A run with `'kraken_mex'` is not bit-identical to one with `'kraken_env'` (log-likelihood within about 0.03), so results of the two should not be mixed inside one chain; a results file stores the name in `scenario.model`.
- The tones are still computed one after another. Computing them in parallel (the wrapper `matlab.kraken.parallel.mac` of the collection, or threads inside the MEX function) is not part of this change; the workers of a run are used by the temperatures.
- The Linux MEX file needs a processor with AVX2 and `libgfortran.so.5`; for another Linux computer rebuild it (`README.md` in `Matlab/KrakenMex`).
- KRAKEN is under the GNU GPL, version 3. The folder carries the licence; the two `kraken.exe` for macOS were already in the repository.

### 50.5 `kraken_mex` is the default (2026-11-19)

Florian Meyer: "Going forward the default should be kraken_mex."

- `scenario.model = 'kraken_mex';` in all six main scripts (`main14L1H.m`, `mainData14L1H.m`, `mainData14L1HContinuous.m`, `mainData14L1HJoint.m`, `mainData14L1HRangeDependent.m`, `mainData14L1HTwoFiles.m`). Every new run uses the MEX function unless the line is changed.
- **Results files written before the flag keep using `kraken.exe`:** a scenario without the field `model`, or with the old name `'Kraken'`, is evaluated with `'kraken_env'` (`getModesSBCEXP22.m`). These runs were computed with `kraken.exe`, and `showResultsData.m` and `checkHeldOutWindows.m` then reproduce their stored log-likelihoods exactly. This includes the two-file run that is still running (its scenario holds `'Kraken'`).
- On a platform without a MEX file (for example an Intel Mac) a run stops at the first call with the message to build it or to set `'kraken_env'` (`SBCEX:krakenUnavailable`).
- `getModesKrakenMexSBCEXP22.m`: depths that coincide (source at a receiver depth, a depth given twice) are returned once by the MEX function; the function now looks only at the rows that were filled.
- Code paths that the checks of Section 50.3 had not used, `kraken_mex` against `kraken_env` (scratch script `checkOtherPaths.m`, results file of the range-dependent run, 16 states):

| | result |
|---|---|
| range-dependent forward model (two mode computations with different profiles, adiabatic modes) | correlation of the fields 0.9999983 or higher; 0.17 s against 0.29 s (1.7 times faster) |
| check of the mode pairing (`getModePairingSBCEXP22.m`, modes on a depth grid of 1 m) | correlations equal to 2e-5 (MAP: 0.989, 0.997, 0.995, 0.990, 0.986 with both) |
| 17 receiver depths with one given twice and the source at a receiver depth | same sizes; the repeated rows are equal; mode shapes within 3e-4 of those of `kraken.exe` |
| two-file forward model after the change of the function | 0.30 s against 0.42 s, correlation 0.9999994 or higher |

## 51. Two-file run: first 10,000 samples, and the present hypothesis on the mismatch (2026-11-19)

Request of Florian Meyer: download the latest results file, say what the results show, and state the present hypothesis on why measured and modelled field still differ. The run was at sample 12,432 of 20,000 (22:18 PST); the latest file is the intermediate one with 10,000 samples (written 18:33 PST).

- On this Mac: `Matlab/Work-in-Progress/GI/resultsDataTwoFilesTmp_run20261118T2114_10000samples.mat` (9.4 MB, same checksum as on the server; not committed).
- Evaluated on the server with `showResultsData.m` (`isZoomMarginals = true`) and `checkHeldOutWindows.m` (100 posterior samples), samples 5,001 to 10,000; forward model `kraken.exe`, as in the run. Figures in `GI/Results`: `SBCEX22_VLA1_two_files_inversion_marginal_posteriors.png`, `..._seabed_sound_speed.png`, `..._samples.png`, `..._posterior_correlations.png`, `..._fit_of_all_frames.png`. They are from the intermediate file and are to be replaced when the run has ended.

### 51.1 Results

| unknown | MAP | mean | standard deviation | 95% interval |
|---|---|---|---|---|
| source range, 2100Z [m] | 1022.3 | 1022.6 | 0.9 | 1021.0 to 1024.3 |
| source range, 2030Z [m] | 989.4 | 989.3 | 0.9 | 987.6 to 991.0 |
| source depth, 2100Z [m] | 121.81 | 121.82 | 0.08 | 121.66 to 121.98 |
| source depth, 2030Z [m] | 125.13 | 125.14 | 0.08 | 124.98 to 125.31 |
| tilt [deg] | -0.04 | -0.04 | 0.02 | -0.09 to 0.01 |
| speed at the top of the sediment [m/s] | 1496 | 1497 | 7 | 1485 to 1510 |
| thickness of the layer [m] | 3.2 | 3.5 | 0.6 | 2.5 to 4.7 |
| speed of the halfspace [m/s] | 1811 | 1831 | 42 | 1749 to 1896 |
| roughness of the seafloor [m] | 0.76 | 0.75 | 0.12 | 0.49 to 0.95 |

Fit of the MAP sample (sample 9,615, log-likelihood 638.50), mean correlation coefficient and cap:

| | fitted frames | cap | held-out frames | cap |
|---|---|---|---|---|
| both files | 0.475 | 0.686 | 0.463 | 0.680 |
| 2100Z | 0.482 | 0.703 | 0.449 | 0.701 |
| 2030Z | 0.468 | 0.669 | 0.478 | 0.659 |
| 100 posterior samples, both files | 0.472 (0.001) | | 0.461 (0.002) | |

By tone, both files, fitted frames (503 to 1253 Hz): 0.574, 0.509, 0.502, 0.427, 0.364.

- **The chain is stationary and has one region.** Samples 5,001 to 10,000 give the estimates of samples 1,001 to 5,000 (Section 46) to within a fraction of a standard deviation; the log-likelihood has stayed at about 634 for 12,000 samples. The sampling found nothing better than the local search that it started from (638.5 against 638.6), and the second seabed of Section 43.3 (lower by 18) is not visited.
- **Geometry.** With the water depth held at the measured 204.0 m, both files put the source at the GPS range for a layback of about 166 m (12.0 m short at 2100Z, where the ship leaves, and 10.5 m beyond at 2030Z, where it approaches; each to 1 m). The array is vertical within 0.1 deg. **The source depths do not agree with each other:** 1.2 m (2100Z) and 4.6 m (2030Z) below the value of the depth sensor, each with a standard deviation of 0.08 m. The offset of the sensor to the transducer is not known, but it is the same in both files; the difference of 3.4 m is not explained.
- **Seabed.** The speed at the seafloor is that of the water above it (1497 against 1503 m/s) and rises by about 95 m/s per m: 1592 (1579 to 1606) m/s at 1 m, 1688 (1656 to 1715) at 2 m, 1780 (1730 to 1817) at 3 m. Below about 3.5 m only a lower limit follows: the halfspace is faster than about 1750 m/s, and its histogram runs into the bound of 1900 m/s. Thickness and halfspace speed are correlated with 0.84: the gradient is determined, not its end.
- **This seabed is not that of the earlier runs** (joint run of the 2100Z file: 1549 m/s at the seafloor, 1588 m/s below 3.5 m). It comes out when both files have to share one seabed and roughness is in the model (Section 41.2). Which of the two is right is not settled by the level of the fit, which is the same.
- **Roughness of the seafloor: 0.75 m.** As a loss of the coherent field the data ask for it clearly (not compatible with zero). As the height of the relief of a sediment seabed the value is large; it may stand for other losses of the steep paths.
- **The level of the fit has not moved:** 0.475 fitted and 0.463 held out, 69% and 68% of the cap, as for the best fit of the 2100Z file alone (0.473 and 0.464, Section 31.5). What is new is that one environment now describes both sides of the array at this level (without roughness: 0.42, Section 37.3).
- **The formal uncertainties are far smaller than the error of the model.** The standard deviations (0.9 m in range, 0.08 m in source depth) hold if the model is right; it reaches two thirds of what is attainable, and the two source depths differ by 40 standard deviations in their offset to the sensor. The intervals should not be quoted as uncertainties of the estimates.

### 51.2 Present hypothesis on the mismatch

Budget of the received power of a frame of 5 s (mean over the tones, 2100Z, Section 34):

| part | share | what it is |
|---|---|---|
| outside the dominant component of the frame | 0.30 | the field changes within the 5 s (the tones are 24 to 44 dB above the background, and the motion of the source explains less than 0.01); it sets the cap at 0.70 |
| in the dominant component, different from frame to frame | 0.13 | not repeatable; no static environment can describe it |
| stable | 0.57 | what a perfect static model could reach; the model has 0.47 to 0.48 of it |

- **Hypothesis for the 0.43 that changes: sound scattered at the moving, rough sea surface, and probably at a seabed that is rough on small scales as the source moves.** A deterministic model with flat interfaces cannot produce it. For it: the time scale of seconds (Section 19); the cap that falls with frequency (0.83 to 0.58); at 503 Hz the arrival from the surface changes its phase most (0.3 to 0.7 rad), the direct arrival least (0.1 to 0.2 rad) (Section 38.5); the changes at 503 and at 653 Hz are unrelated in time, which interference of many contributions gives and a displacement of source, array, or surface does not (Section 40); at 503 Hz the model reaches 0.81 to 0.84 of the attainable for the direct and seabed-reflected sound and 0.53 to 0.55 for the sound from the surface (Section 38.6); and a model that keeps the scattered energy as an incoherent part, with the measured swell and no free value, gives about half of the missing coherence with the right trend in frequency (Section 41.3).
- **The two-file run agrees with this and adds little to it.** Roughness as a loss is the only part of scattering that the forward model has; the data take it (seafloor roughness clearly above zero, joint log-likelihood higher by 30, Section 41.2), the seabed estimate changes, and the level of the fit stays.
- **Ruled out as the cause:** motion of the source in depth (sensor: 0.2 to 0.7 m, cap 0.98 to 0.99); vertical motion of the array; noise of the ship; the tie of the hydrophone depths to the water depth; the shape of the array; densities and attenuations of the seabed; leaky modes; the bathymetry at 1 km (coupled modes at the starting state: no gain).
- **Not explained: the static 0.10** (0.47 against about 0.57). Candidates, none established: the water column between source and array above the loggers and away from the array (only changes of the water column have ever raised the fit; the upper 130 m come from an XBT launched 3.4 km away half an hour later); a seabed that differs between the two sides of the array (each file loses 0.03 to 0.04 with the best environment of the other); and the unexplained 3.4 m between the two source depths, which points to something in the geometry or the profile of the 2030Z file that the model does not have.
- **Not established:** the mechanism itself (no measurement of the sea surface at the reflection points or of the small-scale relief of the seabed); the assumption that the changing part is independent from frame to frame; the sector analysis rests on one tone.

### 51.3 What follows (proposed, not done)

- The target for a static model is about 0.55 to 0.6, not the cap of 0.70, and the present model is at 0.47. Further unknowns of the seabed will not close the gap.
- A likelihood that contains the scattered sound (coherent field plus an incoherent part for each mode, Section 41.3) addresses the larger part; at 2030Z it was better by about 40 per snapshot, fitted and held out. It has not been tried on both files together.
- Alternatively, use only the part of the field that the model can describe: the direct and seabed-reflected arrivals, which carry the information on the seabed. With this array they separate at 503 and 653 Hz only.
- The difference between the two source depths is a concrete, cheap thing to follow up (profile and bathymetry of the 2030Z side).

## 52. Scattered sound in the model without a change of KRAKEN: check at the MAP of the running inversion (2026-11-19)

Questions of Florian Meyer: is scattering modelled in the running inversion, and can the scattered sound be added without changing KRAKEN itself?

- **Running inversion:** roughness acts as a loss of the coherent field only (KRAKEN adds it to the attenuation of each mode; sea surface at the measured value, seafloor as an unknown). The scattered energy is removed, and the likelihood compares each frame with one replica for each tone. The scattered sound is not in the model.
- **Yes, it can be added with KRAKEN unchanged.** The loss by scattering of each mode is the difference of the imaginary parts of its wavenumber between a call with roughness and a call without; the mode shapes are the same. The model of the cross-spectral matrix of a frame is then (coherent field)(coherent field)' plus the sum over the modes of (energy lost to scattering on the way) times (mode shape)(mode shape)'. The scratch test of Section 41.3 was built this way with `kraken.exe`.

Check with the present code (scratch script `scatterModelCheck.m`, `/var/tmp/<user>/tests2`; modes through `getModesSBCEXP22.m` with `'kraken_mex'`; MAP sample 2,577 of the first 10,000 samples: seafloor roughness 0.80 m, layer 3.9 m, 1495 m/s over 1868 m/s; six fitted frames of each file; nothing of the repository changed):

- With and without roughness the mode shapes are identical. The real parts of the wavenumbers change by up to 0.2% for the steepest modes, which the loss removes before the array.
- The loss of both interfaces is the sum of the losses of the two, and each is proportional to the square of its roughness, both to 0.1% of the largest loss. A proposal of a roughness therefore needs no new mode computation.
- Cost: one more mode computation for each file and proposal (0.15 s with `'kraken_mex'`).

| | 503 Hz | 653 Hz | 803 Hz | 1003 Hz | 1253 Hz | mean |
|---|---|---|---|---|---|---|
| 2100Z: loss of the modes by scattering, weighted with their energy at the array [dB/km] | 1.3 | 1.9 | 2.6 | 3.4 | 4.4 | |
| 2100Z: other loss (sediment, halfspace) [dB/km] | 1.2 | 1.4 | 1.5 | 1.6 | 1.7 | |
| 2100Z: share of the energy at the array that the model treats as scattered | 0.23 | 0.30 | 0.36 | 0.40 | 0.45 | 0.35 |
| 2100Z: cap of the model with the scattered sound | 0.786 | 0.718 | 0.667 | 0.628 | 0.579 | 0.676 |
| 2100Z: measured cap | 0.814 | 0.745 | 0.718 | 0.680 | 0.559 | 0.703 |
| 2100Z: measured correlation coefficient of the MAP | 0.597 | 0.514 | 0.497 | 0.436 | 0.365 | 0.482 |
| 2030Z: share of the energy that the model treats as scattered | 0.20 | 0.25 | 0.32 | 0.38 | 0.39 | 0.31 |
| 2030Z: cap of the model with the scattered sound | 0.814 | 0.771 | 0.706 | 0.643 | 0.629 | 0.712 |
| 2030Z: measured cap | 0.758 | 0.682 | 0.676 | 0.627 | 0.601 | 0.669 |
| 2030Z: measured correlation coefficient of the MAP | 0.551 | 0.504 | 0.506 | 0.417 | 0.363 | 0.468 |

- **The roughness that the inversion estimated predicts the measured caps:** 0.68 against 0.70 at 2100Z and 0.71 against 0.67 at 2030Z, with the fall towards the high tones. The inversion did not see the caps (its likelihood uses the normalized replica only), so this is an independent agreement. It supports scattering as the cause of the changes within a frame, and the 0.8 m as the right amount of loss, whatever the relief of the seabed is.
- At the high tones scattering removes more energy on the way (3 to 4 dB/km) than the seabed absorbs (1.6 to 1.7 dB/km).
- **It does not explain the distance between the cap and the fit.** If the scattered sound were incoherent within a frame, as this model assumes, the replica would reach the cap (0.68 to 0.71); it reaches 0.47 to 0.48. That distance is the part of Section 34 that is in the dominant component of a frame but differs from frame to frame (0.13) plus the static mismatch (0.10). A scattered field that changes more slowly than a frame (the swell has a period of 9 s, a frame lasts 5 s) would give the first part; this is consistent with the effective number of snapshots of about 2 for 15 (Section 9), and it is not tested.
- For an implementation, all in MATLAB: the forward model returns, besides the coherent field, the mode shapes at the array and the scattered energy of each mode; a likelihood for the whole cross-spectral matrix (scale and floor for each frame and tone) replaces the present one behind a setting. To decide: the number of independent snapshots of a frame in that likelihood (15 overlapping snapshots; Section 9 supports about 2). Not possible in this way: energy that scattering moves from one mode to another, and a scattered field that stays coherent over a frame. Not implemented.

### 52.1 Decisions of Florian Meyer (2026-11-19, 22:35 PST)

- **The likelihood for the whole cross-spectral matrix counts 2 independent snapshots for each frame** ("Let's keep 2."), the value that the analysis of Section 9 supports. The present likelihood (one replica for each tone, count 1) is not changed by this.
- **Order of the next steps:** wait until the running inversion (Section 44) has ended; then commit everything; then plan the next inversion. Nothing further is implemented or started before that.

## 53. Two-file run: complete run and evaluation (2026-11-20)

- **The run of Section 44 has ended:** 20,000 samples, no errors or warnings in the log, no failed proposal. Started on 2026-11-18 at 21:14 PST; initialization of the proposal covariances until about 01:40 PST; sampling for 115,713 s (32.1 h, 5.8 s per sample) until 2026-11-20, 09:48 PST; final file with the sensitivity analysis at 09:52 PST. No process of this project is running on the server now.
- On this Mac: `Matlab/Work-in-Progress/GI/resultsDataTwoFiles_run20261118T2114_20000samples.mat` (18.6 MB, same checksum as on the server). Its first 10,000 samples are those of the intermediate file of Section 51 (identical values, identical scenario); the final file has the sensitivity analysis in addition. The intermediate file is therefore redundant; it is kept because `CHANGES.md` and `showResultsData.m` name it.
- Evaluated on the server with `showResultsData.m` and `checkHeldOutWindows.m` (100 posterior samples), samples 5,001 to 20,000, forward model `kraken.exe` as in the run (the results file carries the old model name). **Both scripts now point to this file** (`showResultsData.m` with `lastSample = inf` and `isZoomMarginals = true`). The five figures `GI/Results/SBCEX22_VLA1_two_files_inversion_*.png` are replaced by those of the complete run.

### 53.1 Results

| unknown | MAP | mean | standard deviation | 95% interval |
|---|---|---|---|---|
| source range, 2100Z [m] | 1022.3 | 1022.5 | 0.9 | 1020.9 to 1024.3 |
| source range, 2030Z [m] | 989.4 | 989.3 | 0.9 | 987.6 to 991.0 |
| source depth, 2100Z [m] | 121.81 | 121.82 | 0.09 | 121.65 to 121.99 |
| source depth, 2030Z [m] | 125.13 | 125.14 | 0.08 | 124.97 to 125.31 |
| tilt [deg] | -0.04 | -0.04 | 0.03 | -0.09 to 0.01 |
| speed at the top of the sediment [m/s] | 1496 | 1497 | 7 | 1485 to 1511 |
| thickness of the layer [m] | 3.2 | 3.6 | 0.6 | 2.5 to 4.7 |
| speed of the halfspace [m/s] | 1811 | 1832 | 41 | 1751 to 1896 |
| roughness of the seafloor [m] | 0.76 | 0.74 | 0.12 | 0.49 to 0.95 |

Fit of the MAP sample (sample 9,615, log-likelihood 638.50; the same sample as in Section 51), mean correlation coefficient and cap:

| | fitted frames | cap | held-out frames | cap |
|---|---|---|---|---|
| both files | 0.475 | 0.686 | 0.463 | 0.680 |
| 2100Z | 0.482 | 0.703 | 0.449 | 0.701 |
| 2030Z | 0.468 | 0.669 | 0.478 | 0.659 |
| 100 posterior samples, both files | 0.473 (0.001) | | 0.462 (0.002) | |

- **The second half of the run changes nothing.** Every mean is within 0.1 standard deviations of its value from the first 10,000 samples, and the means of the three blocks of 5,000 samples (5,001 to 10,000, 10,001 to 15,000, 15,001 to 20,000) agree with each other to about 0.1 standard deviations. The log-likelihood has a mean of 634.1 in each block (standard deviation 2.2); the largest value of the second half is 638.4, below the MAP of the first half. The chain stayed in one region for all 20,000 samples; the second seabed of Section 43.3 was not visited.
- **Mixing:** the correlation time of every unknown is 4 to 6 samples, so the 15,000 samples used are worth 2,500 to 3,900 independent ones. The run was longer than this posterior needed; half the samples would have given the same numbers.
- **Geometry:** source range minus GPS range -12.0 m (-13.6 to -10.2) at 2100Z and +10.5 m (8.9 to 12.3) at 2030Z, i.e. a layback of about 166 m. The two source depths differ by 3.32 m (standard deviation 0.09 m); the depth sensor read the same in both files to 0.1 m. Unexplained, as in Section 51.1.
- **Seabed:** 1497 m/s at the seafloor, 1545 (1536 to 1554) at 0.5 m, 1592 (1579 to 1606) at 1 m, 1687 (1656 to 1715) at 2 m, 1778 (1730 to 1816) at 3 m; gradient 95 m/s per m (75 to 113). Below about 3.5 m only the lower limit of about 1750 m/s follows; 7% of the samples are within 10 m/s of the bound of 1900 m/s.
- **Correlations:** thickness and halfspace speed 0.83; the two ranges and the two source depths with each other 0.44 to 0.65 (they share the environment); seafloor roughness with the source depths and ranges 0.26 to 0.43 and with the speed at the seafloor -0.35.

### 53.2 What the complete run says

- The findings of Section 51.1 and the hypothesis of Section 51.2 stand without change; the numbers above replace those of the first 10,000 samples.
- With this model and this likelihood nothing more is to be gained from sampling: the posterior is one narrow region around the result of the local search that the run started from, and the fit is where it has been since the logger profile came in (0.47 fitted, 0.46 held out, two thirds of the cap).
- The formal uncertainties remain far smaller than the error of the model and should not be quoted as uncertainties of the estimates (Section 51.1).

## 54. Proposal for the next inversion (2026-11-20; not decided)

Florian Meyer asked to plan the next inversion once the run had ended and everything was committed (Section 52.1). This is the proposal; nothing of it is implemented or started.

**Proposal: the same two files, frames, and unknowns, with the scattered sound in the likelihood.** Reasons: further unknowns of the seabed do not raise the fit (Sections 24, 33, 51.3, 53.2); the scattered sound is the one addition to the model that has independent support, because the roughness estimated by the run predicts the measured caps (Section 52); and KRAKEN need not be changed for it.

1. **Check first (scratch script on the server, minutes, nothing of the repository changed).** Evaluate the likelihood for the whole cross-spectral matrix at the MAP of Section 53 on the fitted and on the held-out frames of both files, with and without the scattered part, and as a function of the seafloor roughness. Go on only if the held-out frames are better with the scattered part and if the likelihood has its maximum at a roughness inside the prior. The risk that this check addresses: the incoherent part could absorb the static error of the model, and the likelihood would then ask for ever more roughness.
2. **Likelihood (behind a setting; the present one stays available, and old results files keep it).** For each tone and frame the model of the matrix is scale x [(coherent field)(coherent field)' + sum over the modes of (energy scattered on the way)(mode shape)(mode shape)'] + floor x identity; scale and floor are maximized for each tone and frame, and the frame counts as 2 independent snapshots (decision of 2026-11-19). Without the scattered part this is close to the present likelihood counted twice.
3. **Forward model.** It returns, besides the coherent field, the mode shapes at the array and the scattered energy of each mode. Two mode computations for each file (with and without roughness); the loss by scattering is proportional to the square of the roughness (Section 52), so a proposal of the roughness needs none.
4. **Mode computations that a proposal does not need (Section 49).** The modes of the current state are kept with the state. Proposals of a range and of the roughness then need no mode computation; a proposal of a source depth needs one file only; a proposal of the tilt needs the mode shapes at new hydrophone depths (the depths change with the cosine of the tilt) but not the second computation without roughness. This is implemented together with step 3, because both change the same functions (`getPressuresFromStateSBCEXP22.m`, `getNextSample.m`).
5. **Scenario.** As the run of Section 44 (two files, six fitted and six held-out frames each, water depth 204.0 m, measured surface roughness, logger profiles, 9 unknowns), with: `scenario.model = 'kraken_mex'`; start at the MAP of Section 53; upper bound of the halfspace speed 2100 m/s instead of 1900 m/s (the posterior leans against 1900 m/s); 20,000 samples with intermediate files every 5,000.
6. **Evaluation.** `showResultsData.m` and `checkHeldOutWindows.m` get the new likelihood of each frame beside the correlation coefficient, and the cap of the model beside the measured cap. The run is an improvement if the held-out frames are better in the new likelihood than the MAP of Section 53 evaluated with the same likelihood.
7. **Cost (estimate, to be measured after the implementation).** Per sample and temperature 16 mode computations instead of 18 (12 for the three unknowns of the seabed, 2 for the source depths, 2 for the tilt), each 0.15 s with the MEX function; so about the 3.6 s per sample of the present script with the MEX function, i.e. about one day for 20,000 samples on a free server. Before the start the clone on the server has to be brought to the committed state.

**To decide (Florian Meyer):** whether this is the direction; the upper bound of the halfspace speed; the number of samples (10,000 would be enough for a posterior as narrow as the present one, Section 53.1).

**Not part of the proposal:** the files at longer range and coupled modes (open points 5 and 13); the count of 2 snapshots in the present likelihood; KRAKEN in parallel over the tones; the 3.3 m between the two source depths, which can be followed up beside the run (profile and bathymetry of the 2030Z side, Section 51.3).
