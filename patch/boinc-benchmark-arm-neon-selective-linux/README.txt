boinc-benchmark-arm-neon-selective-linux

Aim:
Expand on existing source code coverage
Build NEON and VFP version of whetstone benchmark
Selectively choose benchmark based on CPU detection

For:
All Linux (incl. Android) on aarch64, armv7

Pros:
Test the NEON and VFP capabilities

Note:
There really isn't any NEON intrinsics written. The compiler does the job.
