import React, { Component } from 'react'
import {
  View,
  Text,
  Button,
} from 'react-native'
import i18n from 'format-message'

export default class Inbox extends Component {

  showMeTheLegos = () => {
    this.props.navigator.push({
      screen: 'toys.LegoSets',
      title: 'Lego Sets',
    })
  }

  render (): React.Element<{}> {
    return (
      <View>
        <Text>{i18n('This is the inbox')}</Text>
        <Button title={ i18n('And here are the Legos') } onPress={this.showMeTheLegos} />
      </View>
    )
  }
}
