/**
 * @flow
 */

import React, { Component } from 'react'
import { Text } from '../../../common/text'
import { submissionTypes } from '../../../common/submissionTypes'

import {
  View,
  StyleSheet,
} from 'react-native'

export default class SubmissionType extends Component {
  render () {
    const types = submissionTypes()
    return (<View style={style.vertical}>
      {this.props.data.map(item =>
        <Text style={{ flex: 1 }} key={item} testID='assignment-details.submission-type.details-lbl'>{types[item]}</Text>
      )}
    </View>)
  }
}

const style = StyleSheet.create({
  vertical: {
    flexDirection: 'column',
  },
})
