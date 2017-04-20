// @flow

import React, { Component } from 'react'
import {
  ScrollView,
  StyleSheet,
} from 'react-native'
import GradePicker from './components/GradePicker'

export default class GradeTab extends Component {
  render () {
    return (
      <ScrollView style={styles.gradePicker}>
        <GradePicker />
      </ScrollView>
    )
  }
}

const styles = StyleSheet.create({
  gradePicker: {
    paddingHorizontal: 16,
  },
})
