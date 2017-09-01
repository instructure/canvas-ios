// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import colors from '../../colors'

export default class RowSeparator extends Component<any, any, any> {
  render () {
    return <View style={[style.separator, this.props.style]} />
  }
}

var style = StyleSheet.create({
  separator: {
    backgroundColor: colors.seperatorColor,
    height: StyleSheet.hairlineWidth,
  },
})
