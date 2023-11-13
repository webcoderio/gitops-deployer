#!/bin/bash

source shared.sh

# additional build (optional)
pullBuild "$1" "$2"
# additional build (optional)
pushBuild "$1" "$2"
# additional build (optional)
