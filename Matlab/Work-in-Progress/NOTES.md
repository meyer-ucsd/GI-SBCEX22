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

Status: `GI/mainData14L1H.m` still uses the 21:20 file, a single 10 s window, and CTD #20.
