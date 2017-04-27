// @flow

import React, { Component } from 'react'
import {
  ScrollView,
  StyleSheet,
} from 'react-native'
import GradePicker from './components/GradePicker'
import RubricDetails from './components/RubricDetails'

export default class GradeTab extends Component {
  render () {
    return (
      <ScrollView style={styles.gradePicker}>
        <GradePicker {...this.props} />
        <RubricDetails {...this.props} />
      </ScrollView>
    )
  }
}

const styles = StyleSheet.create({
  gradePicker: {
    paddingHorizontal: 16,
  },
})
