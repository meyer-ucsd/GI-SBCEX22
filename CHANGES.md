# Changes

*Last updated 2026-11-15.*

This file lists all changes made to the repository after commit `51f7b00` (2026-09-03), the inversion runs on `meyer01.ucsd.edu`, their results, and the open points. Someone taking over the project should read "Status and open points" first, then Sections 3 and 6 to 13.

## Status and open points (2026-11-15)

**Terminology (from 2026-11-15, Section 23 on):** "frame" means one averaging window of 15 snapshots (about 5 s). Sections 1 to 22 and the code call it "window" or "averaging window" (for example `scenario.windowIndexesFit`); the code names are unchanged.

**Where things stand**

- The inversion of the 21:00 file (`mainData14L1H.m`, 8 unknowns) has 30,000 samples. The run was meant to have 70,000 but was stopped by a server reboot (Section 6). The results are in Section 7.
- A second inversion with a continuous sound speed at the layer interface (`mainData14L1HContinuous.m`, 7 unknowns, 30,000 samples) was started on the server on 2026-11-13 at 22:37 PST (Section 8). Its first 20,000 samples were looked at first (Section 11); the run ended on 2026-11-14 at 11:01 PST (41,947 s, no errors), and the complete file is on this Mac as `resultsDataContinuous_run20261113T2237_30000samples.mat`; `showResultsData.m` and `checkHeldOutWindows.m` point to it; the estimates are the same as for the first 20,000 samples (Section 11).
- Results are shown with `showResultsData.m` (Section 7.1).
- A joint inversion of six windows of the 21:00 file with held-out windows is set up and tested locally (`mainData14L1HJoint.m`, `checkHeldOutWindows.m`, Section 13). It was started on the server on 2026-11-14 at 11:02 PST (Section 13.4). It ended on 2026-11-15 at 02:16 PST with 30,000 samples and no errors. The complete file is on this Mac as `resultsDataJoint_run20261114T1102_30000samples.mat`; results in Section 13.6. The first 10,000 samples already improve the held-out windows (0.448 against 0.420, Section 13.5; preliminary).
- A range-dependent inversion with an EOF profile of the water (`mainData14L1HRangeDependent.m`, Section 16) was started on the server on 2026-11-15 at 14:33 PST (Section 23); expected end around midnight from 2026-11-16 to 2026-11-17. Its control run with the same profile at both ends is not started.
- The baseline for every model change is the fit of the held-out windows. For the single-window inversion: mean Bartlett 0.482 on its own window, 0.421 on the 11 other windows (Section 13.3).

**Open points**

1. Done on 2026-11-15: the complete joint run is downloaded and evaluated (Section 13.6). The thickness leans against its upper prior bound of 5 m; raise the bound in a later run.
2. Effective number of snapshots: the likelihood counts the 15 averaged snapshots as one. The analysis in Section 9 supports a count of 2. This is not applied yet. Both runs use a count of 1, so their posteriors are too wide by roughly 30%.
3. Noise variance of each tone: currently integrated out. Section 10 lists how to obtain or sample it. Not implemented.
4. A halfspace-only inversion as a comparison (is the layer needed at all?). Not set up.
5. The longer-range files (21:10 to 21:30) and the 20:30 file. Not set up. Suggested first step: MFP on the 21:20 file with the current MAP environment (Section 12.3).
8. Sound speed profile of the water with EOF coefficients as unknowns, range dependent: running on the server since 2026-11-15, 14:33 PST (Section 23). To do when it has ended: download and evaluate it as listed in Section 23; decide on the control run (Section 16.5). Open: the data requested from Bill Hodgkiss on 2026-11-15 (temperature loggers of VLA1; Section 22). Assessment of what to expect: Section 20.
6. The MFP peaks and the inversion put the source about 20 to 26 m short of the GPS range in all 12 windows of the 21:00 file. This is expected (Section 7.5): the length of the tow cable is not well known, and bathymetry that changes along the path shifts the estimated range (mirage effect). The two cannot be separated without the bathymetry along the track; a first look at the bathymetry is in Section 17 (source end about 3.6 m deeper than the array end by the 3-arc-second grid; test on the data incomplete).
7. `ReferenceCode/getCovariancesDifferences.m` still has the ordering problem noted in Section 1.

**Committed on 2026-11-15** (the commit after `f0957d7`; see `git log`): everything described in Sections 7 to 25, i.e. `CHANGES.md`, the edit of `Matlab/Work-in-Progress/NOTES.md`, the new and edited files in `Matlab/Work-in-Progress/GI` and `Matlab/Work-in-Progress/MFP`, the figures `GI/Results/*.png` and `MFP/Results/MFP_*_MAP.png`, and the four result files `GI/results*.mat` (73 MB in total), which `showResultsData.m`, `checkHeldOutWindows.m`, and `MFP.m` read. The repository is public: the account name on the server and the details of other projects are left out of this file. Not in the repository: the measurements (`Matlab/Data`, `.gitignore`), the Linux KRAKEN binary, and the results of the run of Section 23, which is still running.

**What a new person needs**

- Data: `Matlab/Data` (SIO files, CTD and XBT casts) is not in the repository (`.gitignore`); get it from Florian Meyer.
- KRAKEN: the repository has binaries for Apple silicon and Intel Macs in `ReferenceCode/bin`. On Linux, put a `kraken.exe` into `ReferenceCode/bin/glnxa64` (Section 6). On a Mac, a binary that came through a download or a file sync can carry the macOS quarantine flag; KRAKEN is then killed at start (exit code 137). Replacing the file with a locally built copy, or removing the flag, fixes it.
- MATLAB: the inversion scripts need the Parallel Computing Toolbox (`parpool`, `parfor`). `showResultsData.m`, `checkEffectiveSnapshots.m`, and `checkHeldOutWindows.m` do not.
- Server: access to `meyer01.ucsd.edu` needs the UCSD VPN and an account; ask Florian Meyer.

| Commit | Date | Content |
|---|---|---|
| `e568966` | 2026-10-14 | Fixes in `ReferenceCode`, SBCEX22 inversion code, first MFP script, LFM script, `.gitignore` |
| `1706288` | 2026-10-14 | MFP rewritten, sound speed profile selection, seabed tuning, data moved to `Matlab/Data` |
| `f0957d7` | 2026-11-11 | Inversion: integrated-out noise variance, setup of the MFP at 21:00, known parameters, ordering fix |
| commit of 2026-11-15 (see `git log`) | 2026-11-15 | Results script, continuous-gradient inversion, snapshot analysis, joint inversion with held-out frames, range-dependent inversion with an EOF profile, MFP with the MAP environment, diagnostics, this file (Sections 7 to 25) |

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
