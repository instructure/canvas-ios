#
# This file is part of Canvas.
# Copyright (C) 1086-present  Instructure, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# see https://github.com/facebook/react-native/issues/10865#issuecomment-302661876
# and here https://github.com/facebook/react-native/pull/10941
# Apparently this is a hot debate in the rn community :)
sed -i '' '/RCTLogError(@"Setting onMessage on a WebView overrides existing values of window.postMessage, but a previous value was defined");/d' node_modules/react-native/React/Views/RCTWebView.m

sed -i '' 's/RCTAnimation/React/' node_modules/react-native/Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h

# https://github.com/facebook/react-native/issues/15808
sed -i '' -e 's/MAX(-contentInset.top, MIN(contentSize.width/MAX(-contentInset.left, MIN(contentSize.width/' node_modules/react-native/React/Views/ScrollView/RCTScrollView.m
sed -i '' -e 's/MAX(-contentInset.left, MIN(contentSize.height/MAX(-contentInset.top, MIN(contentSize.height/' node_modules/react-native/React/Views/ScrollView/RCTScrollView.m

# https://github.com/facebook/react-native/issues/16039
sed -i '' 's#<fishhook/fishhook.h>#\"fishhook.h\"#g' ./node_modules/react-native/Libraries/WebSocket/RCTReconnectingWebSocket.m

# https://github.com/facebook/react-native/issues/18079
# set the warning condition true. (it warns if false)
sed -i '' -e "s/flatStyles == null || flatStyles.flexWrap !== 'wrap'/true/g" ./node_modules/react-native/Libraries/Lists/VirtualizedList.js

# react-native-image-picker is broken in iOS 13
# https://github.com/react-native-community/react-native-image-picker/issues/1179
sed -i '' -e "s/moveItemAtURL:videoURL/copyItemAtURL:videoURL/g" ./node_modules/react-native-image-picker/ios/ImagePickerManager.m
