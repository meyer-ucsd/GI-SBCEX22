# Hydrophone Depths When the Water Depth Is Inferred

*2026-10-31*

Water depth `D` is an unknown in the inversion (state parameter 4, prior 195-205 m). There are two ways to relate the hydrophone depths to it. They give the same geometry at the nominal `D` = 200 m and differ only away from it.

**Used in the GI: option 1 (seafloor-referenced).** It was chosen when the GI was set up because VLA1 is bottom-moored, its height above the seafloor is known from the mooring geometry (trip report, Fig. B.3.3), and the current setup uses no measured hydrophone depths. The two options have not been compared in an inversion.

## Option 1: Seafloor-referenced

The hydrophones stay at fixed heights above the seafloor (7.25 m + (n-1)*3.75 m), so the array moves with `D`.

```
depth(n)  = D - 7.25 - (n-1)*3.75*cos(tilt)
offset(n) = (n-1)*3.75*sin(tilt)
```

- Code: `Matlab/Work-in-Progress/GI/getReceiverGeometrySBCEXP22.m`
- Fits when: the height of the array above the seafloor is known.

## Option 2: Absolute depths

The hydrophones stay at fixed depths below the surface (136.5-192.75 m), so changing `D` only moves the seafloor.

```
depth(n)  = 192.75 - (n-1)*3.75*cos(tilt)
offset(n) = (n-1)*3.75*sin(tilt)
```

- Code: `ReferenceCode/getReceiverDepthOffset.m` (SBCEX17 inversion, with its own receiver depths)
- Fits when: the depths are measured directly, for example by pressure sensors on the array.

## Comparison

n = 1 is the deepest hydrophone; n = 16 is the shallowest. Depths are for zero tilt.

| Water depth `D` | Option 1: depth of n = 1 / n = 16 | Option 1: n = 1 above seafloor | Option 2: depth of n = 1 / n = 16 | Option 2: n = 1 above seafloor |
|---|---|---|---|---|
| 195 m | 187.75 m / 131.5 m | 7.25 m | 192.75 m / 136.5 m | 2.25 m |
| 200 m | 192.75 m / 136.5 m | 7.25 m | 192.75 m / 136.5 m | 7.25 m |
| 205 m | 197.75 m / 141.5 m | 7.25 m | 192.75 m / 136.5 m | 12.25 m |

## Common to Both Options

- The sound speed profile and the source depth are measured from the surface. Under option 1, a change in `D` therefore also shifts the array relative to the sound speed profile and the source; under option 2 it does not.
- The array pivots about the deepest hydrophone, and positive tilt increases the range of the upper hydrophones.
- `Matlab/Work-in-Progress/MFP/MFP.m` uses a fixed `D` of 200 m, where the two options coincide.
