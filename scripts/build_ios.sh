#!/bin/sh
set -e
DIR=$(dirname $0)

if [ -z "$1" ] || [ "$1" = "--help" ]; then
    echo "Usage: ./build_ios.sh [stg|prod]"
    exit 1
fi

if [ "$1" = "stg" ]; then
    echo "Building for staging"

    if [ ! -f "$DIR/GoogleService-Info_stg.plist" ]; then
        echo "GoogleService-Info_stg.plist not found! Please add it to the scripts folder"
        exit 1
    fi

    cp $DIR/GoogleService-Info_stg.plist ios/Runner/GoogleService-Info.plist

    flutter build ipa
elif [ "$1" = "prod" ]; then
    echo "Building for prod"

    if [ ! -f "$DIR/GoogleService-Info_prod.plist" ]; then
        echo "GoogleService-Info-prod.plist not found! Please add it to the scripts folder"
        exit 1
    fi

    cp $DIR/GoogleService-Info_prod.plist ios/Runner/GoogleService-Info.plist

    flutter build ipa
else
    echo "Invalid argument. Please use 'stg' or 'prod'"
    exit 1
fi
