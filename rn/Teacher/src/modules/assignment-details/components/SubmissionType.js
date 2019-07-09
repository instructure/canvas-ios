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
