import React from 'react'
import { Text, View } from 'react-native'
import { TabNavigator, StackNavigator } from 'react-navigation'; // Version can be specified in package.json
import DeepLinkingScreen from './DeepLinking'
import { Ionicons } from '@expo/vector-icons'

const DeepLinkStack = StackNavigator({
  'Deep Linking': { screen: DeepLinkingScreen },
});

export default TabNavigator({
  'Deep Linking': { screen: DeepLinkStack },
},
{
  navigationOptions: ({ navigation }) => ({
    tabBarIcon: ({ focused, tintColor }) => {
      return <Ionicons name={'ios-link-outline'} size={25} color={tintColor} />
    },
  }),
})
