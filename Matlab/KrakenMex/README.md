# KRAKEN as a MEX function (`mkrak`)

The normal-mode program KRAKEN of the Acoustics Toolbox (M. B. Porter), built
as a MATLAB MEX function. The solver is the one of `kraken.exe`; the
environment is passed as MATLAB arrays and the modes come back as arrays, so
no environment file is written and no mode or print file is read.

The inversion code uses it if `scenario.model = 'kraken_mex'`, the setting of
all main scripts since 2026-11-19
(`Matlab/Work-in-Progress/GI/getModesSBCEXP22.m`, which calls
`getModesKrakenMexSBCEXP22.m`). The other settings are `'kraken_env'`
(`kraken.exe` in `ReferenceCode/bin/<platform>` with an environment file; also
used for results files written before the flag existed) and `'orca'` (files
not part of the repository).

## Licence

KRAKEN is distributed under the GNU General Public License, version 3
(`LICENSE` in this folder; the notice is at the top of `kraken_mex.f90`). The
files of this folder, including the two changes listed below, are under that
licence.

## Origin

Copy of the folder `matlab.kraken.inmem.multifreq.mac` of Florian Meyer's
collection of propagation models (files of 2026-04-28): a recent KRAKEN source
with the file input and output replaced (`mkrak.c`, `kraken_mex.f90`,
`KrakenMexInputMod.f90`, `FatalError_mex.f90`), and the routines of the
toolbox that it needs (`misc`).

Changes made for this repository (2026-11-19):

- `kraken_mex.f90`: the print output of the solver (number of modes, time for
  each mesh, warnings) is discarded. Before, it went to a file `fort.6` in the
  current folder, which grew with every call.
- `mkrak.c`: the MEX file stays loaded until MATLAB ends (`mexLock`). Before,
  MATLAB crashed with a segmentation violation when it quit on macOS, after
  the function had been used.
- All text files have Unix line endings (some had Windows line endings).
- `Makefile.macos` (was `Makefile`) and `Makefile.linux`: MATLAB of the two
  computers of this project as default, the optimization of the Makefile of the
  toolbox, the instruction set x86-64-v3 on Linux, and on macOS the Fortran
  runtime linked into the MEX file.

Not copied: the test scripts and the files of the earlier build.

## Call

```
[cg,cp,zm,modes,k] = mkrak(nm,frq,nl,note1,b,nc,ssp,note2,bsig,clh,rng,nsr,zsr,nrc,zrc)
```

| input | meaning |
|---|---|
| `nm` | rows of the outputs: largest number of modes that is returned for a frequency |
| `frq` | frequency [Hz], scalar or vector |
| `nl` | number of media |
| `note1` | three characters as the first options of an environment file: interpolation of the profile, boundary above (`V` vacuum, `R` rigid, `A` halfspace), unit of the attenuation; e.g. `'CVF'` |
| `b` | `nl` x 3: for each medium the number of mesh points (0: 20 points per wavelength), the rms roughness of the interface above it [m], and the depth of its lower end [m] |
| `nc`, `ssp` | number of rows and the rows of the profile: depth, compressional speed, shear speed, density, compressional attenuation, shear attenuation. The media follow each other, each from its upper to its lower end; the last row is the halfspace below |
| `note2` | boundary below (`V`, `R`, `A`) |
| `bsig` | rms roughness of the lowest interface [m] |
| `clh` | smallest and largest phase speed of the modes [m/s] |
| `rng` | largest range [m]; the wavenumbers are refined until their error is small at this range |
| `nsr`, `zsr` | number of source depths and the depths [m] |
| `nrc`, `zrc` | number of receiver depths and the depths [m]; with fewer values than `nrc` the depths are spaced equally between the first and the last value |

| output | meaning |
|---|---|
| `cg`, `cp` | group and phase speeds, frequencies x `nm` |
| `zm` | depths of the mode shapes: source and receiver depths merged and sorted |
| `modes` | mode shapes, depths x `nm` x frequencies |
| `k` | complex wavenumbers, frequencies x `nm` (optional fifth output) |

Rows beyond the last mode of a frequency are zero. An error of KRAKEN is a
MATLAB error with the identifier `mkrak:error`.

Several frequencies are solved one after another in one call. The mesh of each
medium is defined for the highest frequency and scaled in proportion for the
lower ones, and the attenuation is converted for each frequency. The solver
keeps its state in global variables: one MATLAB session computes one call at a
time (the workers of a parallel pool are separate sessions).

Restrictions of this interface: boundaries `V`, `R`, `A` only (no tabulated
reflection coefficients), no profile given by a formula, no rough elastic
interfaces, real arithmetic with losses as a perturbation (KRAKEN, not
KRAKENC).

## Build

A MEX file is needed for each platform; MATLAB finds it by its extension.

| file | platform | built with |
|---|---|---|
| `mkrak.mexmaca64` | macOS, Apple silicon | gfortran 16.2 (Homebrew GCC), MATLAB R2026b; no library of the compiler is needed at run time |
| `mkrak.mexa64` | Linux, x86-64 with AVX2 | gfortran 11.5, MATLAB R2022a; needs `libgfortran.so.5` on the computer |

```
make -f Makefile.macos                                   # macOS; needs gfortran, e.g. from Homebrew (brew install gcc)
make -f Makefile.linux                                   # Linux; needs gfortran and gcc
make -f Makefile.linux MATLABROOT=/usr/local/MATLAB/R2024b    # another MATLAB
```

`OPTFLAGS` in the two files holds the optimization. On Linux the instruction
set matters: without `-march=x86-64-v3` (or `-march=native`) the solver is
about 1.7 times slower. The files written by a build (`*.o`, `*.mod`,
`misc/libmisc.a`) are in `.gitignore`; `make -f <file> clean` removes them and
the MEX file of that platform.

The linker warns on Linux that `kraken_mex.o` requires an executable stack
(the solver passes internal procedures to its root finders). MATLAB loads the
file on the computer of this project; a system that forbids an executable
stack would refuse it.

## Checks (2026-11-19)

Against `kraken.exe` with the environment file, for states of two inversions
(with and without roughness; `CHANGES.md`, Section 50):

- same number of modes at every frequency; real parts of the wavenumbers equal
  to 1 part in a million; correlation of the fields at the array 0.999999 or
  higher; log-likelihood within 0.03;
- time for the modes of the five tones of one file on the Linux computer:
  0.15 s against 0.20 s for states of the two-file inversion (1.36 times
  faster), 0.08 s against 0.13 s for states of the joint inversion; on the Mac
  0.10 s against 0.15 s (joint inversion);
- the complete two-file inversion script with ten temperatures in a parallel
  pool: 3.6 s against 5.0 s per sample.

The small differences come from the environment file, which holds the values
with a few decimals, and from the mode file, which holds the wavenumbers in
single precision.

## SHA-256

```
235b002de9134ce86cfb36bf37f7ce3df86615bb0388f8c0b896ea5d4de8f2fa  mkrak.mexa64
677bcc5da0ba3b7b5cdbd1cae2f0d61c184250ff2bc0c9823f29ec99bdfbd48e  mkrak.mexmaca64
2eef2beb76940ffd83d96fa628b2b9ce61d5084d1597cff774e103909b6fc637  mkrak.c
03f81c9c1cc4c42b2c7bf34b435cfe5465cafff70ae830e0ff8ed51d86c151d0  kraken_mex.f90
```
