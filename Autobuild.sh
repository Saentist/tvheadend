#!/bin/bash
#
# Entry point for the Doozer autobuild system
#
# (c) Andreas Öman 2011. All rights reserved.
#
#

set -eu
trap 'echo "Error on line $LINENO. Exiting."; exit 1' ERR

BUILD_API_VERSION=3
EXTRA_BUILD_NAME=""
JARGS=""
JOBSARGS=""
TARGET=""
ARCHOVR=""
RELEASE="--release"
WORKINGDIR="/var/tmp/showtime-autobuild"
FILELIST="$PWD/filelist.txt"
OP="build"
OSPREFIX=""

function print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -v                 Show build API version"
    echo "  -h                 Show this help message"
    echo "  -t TARGET          Specify the build target (e.g., ubuntu-x86_64)"
    echo "  -e EXTRA_BUILD_NAME  Add extra build name"
    echo "  -j JOBS            Number of parallel jobs"
    echo "  -w WORKINGDIR      Working directory (default: /var/tmp/showtime-autobuild)"
    echo "  -a ARCHOVR         Override architecture"
    echo "  -p OSPREFIX        Add OS prefix to the target"
    echo "  -o OP              Operation to perform (default: build)"
}

while getopts "vht:e:j:w:o:p:a:c:" OPTION; do
    case $OPTION in
        v) echo $BUILD_API_VERSION; exit 0 ;;
        h) print_usage; exit 0 ;;
        t) TARGET="$OPTARG" ;;
        e) EXTRA_BUILD_NAME="$OPTARG" ;;
        j) JOBSARGS="--jobs=$OPTARG"; JARGS="-j$OPTARG" ;;
        w) WORKINGDIR="$OPTARG" ;;
        a) ARCHOVR="$OPTARG" ;;
        p) OSPREFIX="$OPTARG" ;;
        o) OP="$OPTARG" ;;
        *) echo "Invalid option: -$OPTION"; exit 1 ;;
    esac
done

if [[ -z $TARGET ]]; then
    source Autobuild/identify-os.sh
    if [[ -n $ARCHOVR ]]; then
        [[ $ARCHOVR =~ ^(x86_64|arm|arm64)$ ]] || { echo "Invalid ARCHOVR: $ARCHOVR"; exit 1; }
        ARCH=$ARCHOVR
    fi
    TARGET="$DISTRO-$ARCH"
fi

TARGET=$OSPREFIX$TARGET

if [[ ! -d $WORKINGDIR ]]; then
    echo "Working directory $WORKINGDIR does not exist. Creating it..."
    mkdir -p "$WORKINGDIR"
fi

if [[ ! -f Autobuild/${TARGET}.sh ]]; then
    echo "Target script Autobuild/${TARGET}.sh not found!"
    exit 1
fi

echo "Building for $TARGET"
source Autobuild/${TARGET}.sh
