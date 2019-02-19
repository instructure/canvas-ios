if [ ! -f Cartfile ]; then
  cp Cartfile.example Cartfile
fi
if [ ! -f Cartfile.resolved ]; then
  cp Cartfile.resolved.example Cartfile.resolved
fi
carthage bootstrap

pushd
cd rn/Teacher
yarn build
popd
