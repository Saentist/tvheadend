#!/bin/bash
#
# Entry point for the Doozer autobuild system
#
# (c) Andreas Öman 2011. All rights reserved.
#

# Enable strict mode and error handling
set -eu
trap 'echo -e "${RED}[ERROR]${NC} Error on line $LINENO. Exiting."; exit 1' ERR

# Define color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function for colored output
function echo_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

function echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

function echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Initialize variables
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

# Function to display usage
function print_usage() {
    echo_info "Usage: $0 [options]"
    echo_info "Options:"
    echo_info "  -v                 Show build API version"
    echo_info "  -h                 Show this help message"
    echo_info "  -t TARGET          Specify the build target (e.g., ubuntu-x86_64)"
    echo_info "  -e EXTRA_BUILD_NAME  Add extra build name"
    echo_info "  -j JOBS            Number of parallel jobs"
    echo_info "  -w WORKINGDIR      Working directory (default: /var/tmp/showtime-autobuild)"
    echo_info "  -a ARCHOVR         Override architecture"
    echo_info "  -p OSPREFIX        Add OS prefix to the target"
    echo_info "  -o OP              Operation to perform (default: build)"
}

# Parse command-line arguments
while getopts "vht:e:j:w:o:p:a:c:" OPTION; do
    case $OPTION in
        v) echo_success "Build API Version: $BUILD_API_VERSION"; exit 0 ;;
        h) print_usage; exit 0 ;;
        t) TARGET="$OPTARG" ;;
        e) EXTRA_BUILD_NAME="$OPTARG" ;;
        j) JOBSARGS="--jobs=$OPTARG"; JARGS="-j$OPTARG" ;;
        w) WORKINGDIR="$OPTARG" ;;
        a) ARCHOVR="$OPTARG" ;;
        p) OSPREFIX="$OPTARG" ;;
        o) OP="$OPTARG" ;;
        *) echo_error "Invalid option: -$OPTION"; exit 1 ;;
    esac
done

# Determine target if not provided
if [[ -z $TARGET ]]; then
    echo_info "Identifying OS and architecture..."
    source Autobuild/identify-os.sh
    if [[ -n $ARCHOVR ]]; then
        [[ $ARCHOVR =~ ^(x86_64|arm|arm64)$ ]] || { echo_error "Invalid ARCHOVR: $ARCHOVR"; exit 1; }
        ARCH=$ARCHOVR
    fi
    TARGET="$DISTRO-$ARCH"
fi

# Add OS prefix to target
TARGET=$OSPREFIX$TARGET

# Verify the working directory
if [[ ! -d $WORKINGDIR ]]; then
    echo_warning "Working directory $WORKINGDIR does not exist. Creating it..."
    mkdir -p "$WORKINGDIR"
    echo_success "Working directory created: $WORKINGDIR"
fi

# Check if the target script exists
if [[ ! -f "Autobuild/${TARGET}.sh" ]]; then
    echo_error "Target script Autobuild/${TARGET}.sh not found!"
    exit 1
fi

# Start the build process
echo_info "Building for target: $TARGET"
source "Autobuild/${TARGET}.sh"
echo_success "Build process completed for target: $TARGET"
