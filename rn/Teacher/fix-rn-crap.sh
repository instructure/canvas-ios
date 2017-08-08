# see https://github.com/facebook/react-native/issues/10865#issuecomment-302661876
# and here https://github.com/facebook/react-native/pull/10941
# Apparently this is a hot debate in the rn community :)
sed -i '' '/RCTLogError(@"Setting onMessage on a WebView overrides existing values of window.postMessage, but a previous value was defined");/d' node_modules/react-native/React/Views/RCTWebView.m
