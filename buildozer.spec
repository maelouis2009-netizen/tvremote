name: Build APK

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python 3.11
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install system dependencies (CRUCIAL)
        run: |
          sudo apt-get update
          sudo apt-get install -y \
            git \
            zip \
            unzip \
            openjdk-17-jdk \
            autoconf \
            automake \
            libtool \
            pkg-config \
            cmake \
            ninja-build \
            libssl-dev \
            libffi-dev \
            libncurses5 \
            libncursesw5 \
            libtinfo5 \
            libtinfo6 \
            libncurses-dev \
            libncursesw5-dev

      - name: Install Java 17 (Force version)
        run: |
          sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
          sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

      - name: Install Buildozer and Cython
        run: |
          pip install --upgrade pip
          pip install buildozer cython==0.29.36 virtualenv

      - name: Build APK with Buildozer
        run: |
          # Force l'autorisation root pour GitHub Actions
          export BUILDOZER_ALLOW_ROOT=1
          
          # Nettoie les anciens builds pour éviter les conflits
          buildozer android clean
          
          # Lance la compilation avec des logs verbeux
          buildozer -v android debug
        env:
          BUILDOZER_ALLOW_ROOT: 1

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: tvremote-apk
          path: bin/*.apk
          if-no-files-found: error
