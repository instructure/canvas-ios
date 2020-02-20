//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow
import React, { Component } from 'react'
import {
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'
import { Text } from '../../../common/text'
import { colors } from '../../../common/stylesheet'

type SubmissionStatusLabelProps = {
  status: SubmissionStatus,
  onlineSubmissionType?: boolean,
  style?: any,
}

export default class SubmissionStatusLabel extends Component<SubmissionStatusLabelProps, any> {
  render () {
    let submission = this.props.submission || {}

    if (submission.excused) return null

    let color: string = colors.textDark // none
    let title: string = i18n('Not Submitted')

    if (submission.late) {
      color = colors.textWarning
      title = i18n('Late')
    } else if (submission.missing) {
      color = colors.textDanger
      title = i18n('Missing')
    } else if (submission.submittedAt != null || submission.submitted_at != null) {
      color = colors.textSuccess
      title = i18n('Submitted')
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
