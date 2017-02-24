import React, { Component } from 'react'
import {
  View,
  Text,
  Button,
  NativeModules,
} from 'react-native'

export default class Profile extends Component {

  logout () {
    const nativeLogin = NativeModules.NativeLogin
    nativeLogin.logout()
  }

  render () {
    return (
      <View testID="module.profile" accessible={true}>
        <Text>This is the profile</Text>
        <Button
          onPress={this.logout.bind(this)}
          title="Logout" />
        </View>
    )
  }
}
