# Make sure build step sees watchman directory
export PATH=/opt/homebrew/bin:$PATH
watchman --version

export NODE_OPTIONS=--openssl-legacy-provider

export NODE_BINARY=node
cd ../rn/Teacher
./node_modules/react-native/scripts/react-native-xcode.sh