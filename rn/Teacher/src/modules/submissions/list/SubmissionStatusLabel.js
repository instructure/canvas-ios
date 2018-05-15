//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow
import React, { Component } from 'react'
import {
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'

type SubmissionStatusLabelProps = {
  status: SubmissionStatus,
  onlineSubmissionType?: boolean,
  style?: any,
}

export default class SubmissionStatusLabel extends Component<SubmissionStatusLabelProps, any> {
  render () {
    let color: string = '#8B969E' // none
    let title: string = i18n('Not Submitted')

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
      case 'resubmitted':
        color = '#07AF1F'
        title = i18n('Submitted')
        break
      case 'excused':
        title = i18n('Excused')
        break
    }

    if (this.props.onlineSubmissionType !== undefined && !this.props.onlineSubmissionType) { title = '' }

    return <Text style={[styles.statusText, this.props.style, { color }]}>{title}</Text>
  }
}

const styles = StyleSheet.create({
  statusText: {
    fontSize: 14,
    paddingTop: 2,
  },
})
