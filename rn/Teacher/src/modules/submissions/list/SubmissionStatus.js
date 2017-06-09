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
    let title: string = i18n('No submission')

    switch (this.props.status) {
      case 'late':
        color = '#FC5E13'
        title = i18n('Late')
        break
      case 'missing':
        color = '#EE0612'
        title = i18n('Missing')
        break
      case 'submitted':
        color = '#07AF1F'
        title = i18n('Submitted')
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
