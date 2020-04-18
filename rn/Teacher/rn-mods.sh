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

# https://github.com/facebook/react-native/issues/18079
# set the warning condition true. (it warns if false)
sed -i '' -e "s/flatStyles == null || flatStyles.flexWrap !== 'wrap'/true/g" ./node_modules/react-native/Libraries/Lists/VirtualizedList.js

# react-native-image-picker is broken in iOS 13
# https://github.com/react-native-community/react-native-image-picker/issues/1179
sed -i '' -e "s/moveItemAtURL:videoURL/copyItemAtURL:videoURL/g" ./node_modules/react-native-image-picker/ios/ImagePickerManager.m
