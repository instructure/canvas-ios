import React, { Component } from 'react'
import {
  View,
  Text,
} from 'react-native'
import i18n from 'format-message'

export default class Inbox extends Component {

  render () {
    return (
      <View>
        <Text>{i18n('This is the inbox')}</Text>
      </View>
    )
  }
}
