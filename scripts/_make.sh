#!/usr/bin/env bash
FUNCTION=$1
# Load functions
source $(dirname "${BASH_SOURCE[0]}")/_functions.sh
# Execute function
eval ${FUNCTION}