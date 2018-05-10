//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import React from 'react'
import { Text, View } from 'react-native'
import { TabNavigator, StackNavigator, DrawerNavigator } from 'react-navigation'; // Version can be specified in package.json
import DeepLinkingScreen from './DeepLinking'
import NavigationTestScreen from './NavigationTest'
import { Ionicons } from '@expo/vector-icons'

const DeepLinkStack = StackNavigator({
  'Deep Linking': { screen: DeepLinkingScreen },
});

const NavigationTestStack = StackNavigator({
  'Navigation Test': { screen: NavigationTestScreen },
});

export default TabNavigator({
  'Deep Linking': { screen: DeepLinkStack },
  'Navigation Test': { screen: NavigationTestStack },
},
{
  navigationOptions: ({ navigation }) => ({
    tabBarIcon: ({ focused, tintColor }) => {
      switch (navigation.state.key) {
        case 'Deep Linking':
          return <Ionicons name={'ios-link-outline'} size={25} color={tintColor} />
        case 'Navigation Test':
          return <Ionicons name={'ios-car-outline'} size={25} color={tintColor} />
      }
    },
  }),
})
