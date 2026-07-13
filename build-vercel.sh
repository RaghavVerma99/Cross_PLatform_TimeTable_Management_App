#!/bin/bash

# Exit on error
set -e

echo "=========================================================="
echo "🚀 STARTING FLUTTER WEB BUILD FOR VERCEL"
echo "=========================================================="

# 1. Clone Flutter stable branch with depth 1 to speed up builds
if [ ! -d "flutter" ]; then
  echo "📦 Cloning Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
else
  echo "🔄 Flutter SDK already exists. Fetching updates..."
  cd flutter
  git fetch --depth 1
  git reset --hard origin/stable
  cd ..
fi

# 2. Expose the Flutter bin directory to the PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Verify path and check installation
flutter --version

# 4. Enable Web building support
echo "⚙️ Configuring Flutter Web..."
flutter config --enable-web

# 5. Automatically generate the web/ subdirectory
echo "📂 Rebuilding project platform templates..."
flutter create --overwrite .

# 6. Retrieve package dependencies
echo "📥 Fetching pub packages..."
flutter pub get

# 7. Compile the application to static Web files
echo "⚡ Building Flutter Web release bundle..."
flutter build web --release

echo "=========================================================="
echo "🎉 BUILD SUCCESSFUL! Files are ready in build/web"
echo "=========================================================="
