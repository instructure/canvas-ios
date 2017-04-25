// @flow
import React, { Component } from 'react'
import {
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import type {
  SubmissionStatusProp,
} from './submission-prop-types'
import { Text } from '../../../common/text'

type SubmissionStatusProps = {
  status: SubmissionStatusProp,
}

export default class SubmissionStatus extends Component<any, SubmissionStatusProps, any> {

  render (): React.Element<*> {
    let color: string = '#8B969E' // none
    let title: string = i18n({
      default: 'No submission',
      description: 'No submission from the student for the given assignment',
    })

    switch (this.props.status) {
      case 'late':
        color = '#FC5E13'
        title = i18n({
          default: 'Late',
          description: 'Assignment was turned in late',
        })
        break
      case 'missing':
        color = '#EE0612'
        title = i18n({
          default: 'Missing',
          description: 'The assignment has not been turned in',
        })
        break
      case 'submitted':
        color = '#07AF1F'
        title = i18n({
          default: 'Submitted',
          description: 'The assignment has been turned in',
        })
        break
    }

    return <Text style={[styles.statusText, { color }]}>{title}</Text>
  }
}

const styles = StyleSheet.create({
  statusText: {
    fontSize: 14,
    paddingTop: 2,
  },
})
