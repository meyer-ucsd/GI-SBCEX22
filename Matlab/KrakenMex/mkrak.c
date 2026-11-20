#include "mex.h"
#include "matrix.h"

void kraken_mex_(
    int *nm,
    double *frq,
    int *frq_count,
    int *nl,
    char *note1,
    double *bb,
    int *nc,
    double *ssp,
    char *note2,
    double *bsig,
    double *clh,
    double *rng,
    int *nsr,
    double *zsr,
    int *zsr_count,
    int *nrc,
    double *zrc,
    int *zrc_count,
    int *nz,
    double *cg,
    double *cp,
    double *zm,
    double *modes,
    double *k_re,
    double *k_im
);

void kraken_mex_fatal(const char *message) {
    mexErrMsgIdAndTxt("mkrak:error", "%s", message);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double bsig, rng;
    double *frq, *bb, *ssp, *clh, *zsr, *zrc;
    double *cg, *cp, *zm, *modes, *k_re_temp, *k_im_temp;
    int nm, frq_count, nl, nc, nsr, nrc, nz;
    int zsr_count, zrc_count;
    char *note1, *note2;
    int buflen1, buflen2;
    mwSize output_count;
    mwSize i;
    mwSize mode_dims[3];

    /* Change for the SBCEX22 inversion code (2026-11-19): the MEX file stays
       loaded until MATLAB ends. The runtime of the Fortran compiler registers
       clean-up code for each thread that has called it; if MATLAB unloads the
       MEX file before that thread ends (at shutdown, or with "clear mex"), the
       clean-up code is gone and MATLAB crashes with a segmentation violation
       (seen on macOS when MATLAB quits). */
    if (!mexIsLocked()) {
        mexLock();
    }

    if (nrhs != 15) {
        mexErrMsgIdAndTxt("mkrak:error", "mkrak requires 15 input arguments.");
    }
    if (nlhs != 4 && nlhs != 5) {
        mexErrMsgIdAndTxt("mkrak:error", "mkrak requires 4 outputs, or 5 outputs when requesting modal wavenumbers.");
    }

    buflen1 = (int) (mxGetNumberOfElements(prhs[3]) + 1);
    buflen2 = (int) (mxGetNumberOfElements(prhs[7]) + 1);

    note1 = mxCalloc((mwSize) buflen1, sizeof(char));
    note2 = mxCalloc((mwSize) buflen2, sizeof(char));

    nm = (int) mxGetScalar(prhs[0]);
    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || mxIsEmpty(prhs[1])) {
        mexErrMsgIdAndTxt("mkrak:error", "frq must be a non-empty real double vector.");
    }
    frq = mxGetPr(prhs[1]);
    frq_count = (int) mxGetNumberOfElements(prhs[1]);
    nl = (int) mxGetScalar(prhs[2]);
    mxGetString(prhs[3], note1, (mwSize) buflen1);
    bb = mxGetPr(prhs[4]);
    nc = (int) mxGetScalar(prhs[5]);
    ssp = mxGetPr(prhs[6]);
    mxGetString(prhs[7], note2, (mwSize) buflen2);
    bsig = mxGetScalar(prhs[8]);
    clh = mxGetPr(prhs[9]);
    rng = mxGetScalar(prhs[10]);
    nsr = (int) mxGetScalar(prhs[11]);
    zsr = mxGetPr(prhs[12]);
    nrc = (int) mxGetScalar(prhs[13]);
    zrc = mxGetPr(prhs[14]);

    zsr_count = (int) mxGetNumberOfElements(prhs[12]);
    zrc_count = (int) mxGetNumberOfElements(prhs[14]);
    nz = nsr + nrc;

    plhs[0] = mxCreateDoubleMatrix((mwSize) frq_count, (mwSize) nm, mxREAL);
    plhs[1] = mxCreateDoubleMatrix((mwSize) frq_count, (mwSize) nm, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nz, 1, mxREAL);
    if (frq_count == 1) {
        plhs[3] = mxCreateDoubleMatrix((mwSize) nz, (mwSize) nm, mxREAL);
    } else {
        mode_dims[0] = (mwSize) nz;
        mode_dims[1] = (mwSize) nm;
        mode_dims[2] = (mwSize) frq_count;
        plhs[3] = mxCreateNumericArray(3, mode_dims, mxDOUBLE_CLASS, mxREAL);
    }

    cg = mxGetPr(plhs[0]);
    cp = mxGetPr(plhs[1]);
    zm = mxGetPr(plhs[2]);
    modes = mxGetPr(plhs[3]);

    output_count = (mwSize) frq_count * (mwSize) nm;
    k_re_temp = mxCalloc(output_count, sizeof(double));
    k_im_temp = mxCalloc(output_count, sizeof(double));

    if (nlhs == 5) {
        plhs[4] = mxCreateDoubleMatrix((mwSize) frq_count, (mwSize) nm, mxCOMPLEX);
    }

    kraken_mex_(
        &nm,
        frq,
        &frq_count,
        &nl,
        note1,
        bb,
        &nc,
        ssp,
        note2,
        &bsig,
        clh,
        &rng,
        &nsr,
        zsr,
        &zsr_count,
        &nrc,
        zrc,
        &zrc_count,
        &nz,
        cg,
        cp,
        zm,
        modes,
        k_re_temp,
        k_im_temp
    );

    if (nlhs == 5) {
        mxComplexDouble *k_out = mxGetComplexDoubles(plhs[4]);
        for (i = 0; i < output_count; ++i) {
            k_out[i].real = k_re_temp[i];
            k_out[i].imag = k_im_temp[i];
        }
    }

    mxFree(k_re_temp);
    mxFree(k_im_temp);
    mxFree(note1);
    mxFree(note2);
}
