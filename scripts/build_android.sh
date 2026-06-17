#!/bin/sh
set -e
DIR=$(dirname $0)

if [ -z "$1" ] || [ "$1" = "--help" ]; then
    echo "Usage: ./build_android.sh [stg|prod]"
    exit 1
fi

if [ "$1" = "stg" ]; then
    echo "Building for staging"

    flutter build apk --release
elif [ "$1" = "prod" ]; then
    echo "Building for prod"

    flutter build appbundle
else
    echo "Invalid argument. Please use 'stg' or 'prod'"
    exit 1
fi
