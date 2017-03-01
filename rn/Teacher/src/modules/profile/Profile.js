import React, { Component } from 'react'
import {
  View,
  Text,
  Button,
  NativeModules,
} from 'react-native'
import i18n from 'format-message'

export default class Profile extends Component {

  logout () {
    const nativeLogin = NativeModules.NativeLogin
    nativeLogin.logout()
  }

  render (): React.Element {
    return (
      <View testID="module.profile" accessible={true}>
        <Text>{i18n('This is the profile')}</Text>
        <Button
          onPress={this.logout.bind(this)}
          title={i18n('Logout')} />
        </View>
    )
  }
}
