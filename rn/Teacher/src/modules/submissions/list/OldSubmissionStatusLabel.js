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

type OldSubmissionStatusLabelProps = {
  status: SubmissionStatus,
  onlineSubmissionType?: boolean,
  style?: any,
}

export default class OldSubmissionStatusLabel extends Component<OldSubmissionStatusLabelProps, any> {
  render () {
    let color: string = colors.textDark // none
    let title: string = i18n('Not Submitted')

    switch (this.props.status) {
      case 'late':
        color = colors.textWarning
        title = i18n('Late')
        break
      case 'missing':
        color = colors.textDanger
        title = i18n('Missing')
        break
      case 'submitted':
      case 'resubmitted':
        color = colors.textSuccess
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
