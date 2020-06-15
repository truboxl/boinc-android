# truboxl/boinc-feature-patch

## Experimental feature patches for BOINC

### Instructions

To apply patch, change to BOINC source directory and:

    git apply <path_to_patch_folder>/<feature_folder>/*.patch

Example:

    cd src/boinc
    git apply ../../patch/boinc-termux-client-patch/*.patch

### Notes

These are some patches written to build custom version of BOINC that has some experimental features. Usually these features are not accepted upstream due to various reasons.

I should clarify that these patches here are EXPERIMENTAL. Use at your own risk. Patches here licensed under MIT License.
