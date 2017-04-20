// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Heading1 } from '../../../common/text'

export default class GradePicker extends Component {
  render () {
    return (
      <View style={styles.gradeCell}>
        <Heading1>{i18n('Grade')}</Heading1>
        <Heading1>4.0</Heading1>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  gradeCell: {
    height: 48,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgray',
  },
})
