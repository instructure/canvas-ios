import React from 'react';
import { Text, View } from 'react-native';
import { TabNavigator, StackNavigator } from 'react-navigation'; // Version can be specified in package.json

class DeepLinkingScreen extends React.Component {

  static navigationOptions = {
    title: 'Deep Linking',
  };

  render() {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>This is where deep linking will go.</Text>
      </View>
    );
  }
}

const DeepLinkStack = StackNavigator({
  'Deep Linking': { screen: DeepLinkingScreen },
});

export default TabNavigator({
  'Deep Linking': { screen: DeepLinkStack },
});
