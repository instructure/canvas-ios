# see https://github.com/facebook/react-native/issues/10865#issuecomment-302661876
# and here https://github.com/facebook/react-native/pull/10941
# Apparently this is a hot debate in the rn community :)
sed -i '' '/RCTLogError(@"Setting onMessage on a WebView overrides existing values of window.postMessage, but a previous value was defined");/d' node_modules/react-native/React/Views/RCTWebView.m

sed -i '' 's/RCTAnimation/React/' node_modules/react-native/Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h

# https://github.com/facebook/react-native/issues/15808
sed -i '' -e 's/MAX(-contentInset.top, MIN(contentSize.width/MAX(-contentInset.left, MIN(contentSize.width/' node_modules/react-native/React/Views/RCTScrollView.m
sed -i '' -e 's/MAX(-contentInset.left, MIN(contentSize.height/MAX(-contentInset.top, MIN(contentSize.height/' node_modules/react-native/React/Views/RCTScrollView.m

# https://github.com/facebook/react-native/issues/16039
sed -i '' 's#<fishhook/fishhook.h>#\"fishhook.h\"#g' ./node_modules/react-native/Libraries/WebSocket/RCTReconnectingWebSocket.m

# https://github.com/facebook/react-native/issues/18079
# set the warning condition true. (it warns if false)
sed -i '' -e "s/flatStyles == null || flatStyles.flexWrap !== 'wrap'/true/g" ./node_modules/react-native/Libraries/Lists/VirtualizedList.js

# https://github.com/facebook/react-native/issues/16039
sed -i '' 's/self.delegate = self;/self.delegate = self;\
    [self selectRow:0 inComponent:0 animated:YES];/' ./node_modules/react-native/React/Views/RCTPicker.m