#!/bin/bash
set -e

WD=$(pwd)

build_web() {
    flutter build web
    cp ./avatar_list.txt build/web/
}

deploy_web() {
    flutter build web
    cp ./avatar_list.txt build/web/
    firebase deploy
}

build_apk() {
    flutter build apk
}

build_iOS() {
    flutter build ios
}

iOS_archive() {
    cd build/ios/iphoneos/
    mkdir Payload
    cp -r Runner.app Payload/
    zip Payload.zip -r Payload > /dev/null
    mv Payload.zip Payload.ipa
    rm -rf Payload/
    cd $WD
}

tmux_build_all() {
    tmux new-session -s "flutter_build" -d
    tmux send -t "flutter_build" "flutter build web --release && cp ./avatar_list.txt build/web/ && firebase deploy && exit" Enter
    tmux split-window -h
    tmux send -t "flutter_build" "flutter build apk && exit" Enter
    tmux split-window -v
    tmux send -t "flutter_build" "flutter build ios && ./build.sh archive && exit" Enter
    tmux -2 attach-session -d
}

build_all() {
    build_web &
    build_apk &
    build_iOS_archive &
}

print_help() {
    printf "Usage: $0 [-h] [apk] [ipa] [web] [all] [tmx] [deploy]
    -h : show this help page
    apk: build Android installation package
    ipa: build iOS installation package
    web: build website content
    all: build all
    tmx: build all with tmux splited screen
    deploy: build website content and deploy to firebase\n"
}

if [ $# -gt 0 ]; then
    for arg in "$@"; do
        if [ "$arg"x = "-h"x ]; then
            print_help
        elif [ "$arg"x = "apk"x ]; then
            flutter clean
            flutter pub get
            build_apk
            exit
        elif [ "$arg"x == "ipa"x ]; then
            flutter clean
            flutter pub get
            build_iOS
            iOS_archive
            exit
        elif [ "$arg"x == "web"x ]; then
            flutter clean
            flutter pub get
            build_web
            exit
        elif [ "$arg"x == "all"x ]; then
            flutter clean
            flutter pub get
            build_all
            exit
        elif [ "$arg"x == "tmx"x ]; then
            flutter clean
            flutter pub get
            tmux_build_all
            exit
        elif [ "$arg"x == "deploy"x ]; then
            flutter clean
            flutter pub get
            deploy_web
            exit
        elif [ "$arg"x == "archive"x ]; then
            iOS_archive
            exit
        fi
    done
else
    print_help
fi


