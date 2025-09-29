#!/usr/bin/env sh

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
# Ensure cmdline-tools/latest exists
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]; then
  # Brew installs under "latest" now, but just in case link it
  TOOLS_DIR="$(brew --prefix)/share/android-commandlinetools"
  if [ -d "$TOOLS_DIR" ]; then
    ln -snf "$TOOLS_DIR" "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  fi
fi

echo "==> Accepting Android licenses & installing packages"
yes | sdkmanager --licenses >/dev/null

sdkmanager \
  "platform-tools" \
  "emulator" \
  "platforms;android-36" \
  "build-tools;36.0.0" \
  "system-images;android-36;google_apis;arm64-v8a"

# ---------- Create default Android AVD ----------
echo "Creating default Android AVD (if missing)"
AVD_NAME="Medium_Phone_API_36.0"
if ! emulator -list-avds | grep -q "^${AVD_NAME}$"; then
    avdmanager create avd \
    -n $AVD_NAME \
    -k "system-images;android-36;google_apis;arm64-v8a" \
    -d "Medium Phone"
  echo "Created AVD: $AVD_NAME"
else
  echo "AVD already exists: $AVD_NAME"
fi
