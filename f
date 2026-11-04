name: Build APK

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python 3.11
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential git python3-pip python3-dev ffmpeg libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libportmidi-dev libswscale-dev libavformat-dev libavcodec-dev zlib1g-dev libgstreamer1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good autoconf libtool pkg-config
          pip install buildozer cython==0.29.36

      - name: Build APK with Buildozer
        run: |
          export BUILDOZER_ALLOW_ROOT=1
          cat > buildozer.spec << 'EOF'
          [app]
          title = TV Remote
          package.name = tvremote
          package.domain = org.louis
          source.dir = .
          source.include_exts = py,png,jpg,jpeg,webp
          source.include_patterns = assets/*
          version = 1.0
          requirements = python3==3.11.8,kivy==2.3.0,adb_shell,rsa,Pillow,pyjnius
          orientation = portrait
          fullscreen = 0
          android.permissions = INTERNET,ACCESS_NETWORK_STATE
          android.api = 33
          android.minapi = 21
          android.archs = arm64-v8a
          android.accept_sdk_license = True
          [buildozer]
          log_level = 2
          warn_on_root = 1
          EOF
          buildozer -v android debug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: tvremote-apk
          path: bin/*.apk
