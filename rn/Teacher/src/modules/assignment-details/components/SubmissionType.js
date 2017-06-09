/**
 * @flow
 */

import React, { Component } from 'react'
import { Text } from '../../../common/text'
import { SUBMISSION_TYPES } from '../../../common/submissionTypes'

import {
  View,
  StyleSheet,
} from 'react-native'

export default class SubmissionType extends Component {
  render () {
    return (<View style={style.vertical}>
      {this.props.data.map(item =>
        <Text style={{ flex: 1 }} key={item}>{SUBMISSION_TYPES[item]}</Text>
      )}
    </View>)
  }
}

const style = StyleSheet.create({
  vertical: {
    flexDirection: 'column',
  },
})
