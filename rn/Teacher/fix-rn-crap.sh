# see https://github.com/facebook/react-native/issues/10865#issuecomment-302661876
# and here https://github.com/facebook/react-native/pull/10941
# Apparently this is a hot debate in the rn community :)
sed -i '' '/RCTLogError(@"Setting onMessage on a WebView overrides existing values of window.postMessage, but a previous value was defined");/d' node_modules/react-native/React/Views/RCTWebView.m

sed -i '' 's/RCTAnimation/React/' node_modules/react-native/Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h

# https://github.com/facebook/react-native/issues/15808
sed -i '' -e 's/MAX(0, MIN(originalOffset.x/MAX(-contentInset.left, MIN(originalOffset.x/' node_modules/react-native/React/Views/RCTScrollView.m
sed -i '' -e 's/MAX(0, MIN(originalOffset.y/MAX(-contentInset.top, MIN(originalOffset.y/' node_modules/react-native/React/Views/RCTScrollView.m

