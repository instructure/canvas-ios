// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import Screen from './Screen'
import i18n from 'format-message'
import { Text } from '../common/text'
import colors from '../common/colors'

export default class ErrorScreen extends Component<*> {
  render () {
    let screenProps = {}
    if (!this.props.navigator.isModal) {
      screenProps.navBarColor = colors.navBarColor
      screenProps.navBarStyle = 'dark'
    }
    return (
      <Screen
        title={i18n('Error')}
        {...screenProps}
      >
        <View style={styles.container}>
          <Text style={styles.heading}>{i18n('Whoops!')}</Text>
          <Text style={styles.text}>
            {i18n("Something went wrong on our end. Don't worry, we've recorded this and will be taking care of it shortly.")}
          </Text>
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  heading: {
    fontSize: 32,
    fontWeight: '300',
    margin: 8,
  },
  text: {
    textAlign: 'center',
  },
})
