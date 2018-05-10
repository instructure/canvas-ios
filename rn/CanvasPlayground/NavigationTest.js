import React from 'react'
import { 
  Text,
  View,
  Button,
} from 'react-native';

export default class NavigationTestScreen extends React.Component {

  state = {
    items: [],
  }

  static navigationOptions = {
    title: 'Navigation Test',
  };

  pushTest = () => {
    this.props.navigation.navigate('Navigation Test')
  }

  render () {
    return (<View style={{ flex: 1, backgroundColor: 'white', alignContent: 'center', justifyContent: 'center' }}>
              <Button title="Push a new thing" onPress={this.pushTest} />
            </View>)
  }
}
