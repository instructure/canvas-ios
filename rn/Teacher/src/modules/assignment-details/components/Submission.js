/**
 * @flow
 */

import React, { Component } from 'react'
import SubmissionGraph from './SubmissionGraph'

import {
  View,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'

export default class Submission extends Component {
  render (): ReactElement<*> {
    let graded = i18n({
      default: 'Graded',
      description: 'Assignemnt Details submissions graph `graded`',
    })

    let ungraded = i18n({
      default: 'Ungraded',
      description: 'Assignemnt Details submissions graph `graded`',
    })

    let notSubmitted = i18n({
      default: 'Not Submitted',
      description: 'Assignemnt Details submissions graph `graded`',
    })

    let labels = [graded, ungraded, notSubmitted]
    console.log(this.props.data)
    return (
      <View style={[submissionStyle.container, this.props.style]}>
        {this.props.data.map((item, index) =>
          <SubmissionGraph label={labels[index]} data={this.props.data[index]} key={index}/>
        )}
      </View>
    )
  }
}

const submissionStyle = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
})
