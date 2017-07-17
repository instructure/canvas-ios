# see https://github.com/facebook/react-native/issues/10865#issuecomment-302661876
# and here https://github.com/facebook/react-native/pull/10941
# Apparently this is a hot debate in the rn community :)
sed -i '' '/RCTLogError(@"Setting onMessage on a WebView overrides existing values of window.postMessage, but a previous value was defined");/d' node_modules/react-native/React/Views/RCTWebView.m

cd ./node_modules/react-native/scripts
curl https://raw.githubusercontent.com/facebook/react-native/5c53f89dd86160301feee024bce4ce0c89e8c187/scripts/ios-configure-glog.sh >ios-configure-glog.sh
