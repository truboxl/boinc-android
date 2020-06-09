# truboxl/boinc-android

## Cleaner build scripts for building BOINC for Android app

## Prerequisite

* autoconf
* automake
* curl
* git
* libtool
* m4
* make
* perl
* pkg-config
* tar
* unzip

## Steps

1. Clone and open this repository
1. Check and edit `./00_prepare_sources.sh` if necessary
1. Run `./00_prepare_sources.sh` to prepare all the sources
1. Run `./99_build_boinc_all.sh` to compile BOINC for Android
1. Run Android Studio and open `./src/boinc/android/BOINC`
1. ???
1. Profit!

## Clean up

1. Run `./00_clean_buildcache.sh`
1. Run `. ./unset_env.sh`

### Note: Long term should look into directly build from Android Studio if possible
