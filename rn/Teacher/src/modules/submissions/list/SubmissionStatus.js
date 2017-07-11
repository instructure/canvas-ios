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

  render () {
    let color: string = '#8B969E' // none
    let title: string = i18n('Not Submitted')

    switch (this.props.status) {
      case 'late':
        color = '#FC5E13'
        title = i18n('LATE')
        break
      case 'missing':
        color = '#EE0612'
        title = i18n('MISSING')
        break
      case 'submitted':
        color = '#07AF1F'
        title = i18n('SUBMITTED')
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
