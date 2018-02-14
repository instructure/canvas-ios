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

export default class SubmissionType extends Component<Object> {
  render () {
    if (!this.props.data) return null
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
