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

import React, { PureComponent } from 'react'
import {
  View,
  Text,
} from 'react-native'
import { createStyleSheet } from '../stylesheet'

type Props = {
  text: string,
  testID: string,
}

export default class DescriptionDefaultView extends PureComponent<Props, any> {
  static defaultProps = {
    text: 'Help your students with this assignment by adding instructions.',
  }

  render () {
    return (
      <View style={[styles.container]} testID={`${this.props.testID}.view`}>
        <Text style={styles.text}>{this.props.text}</Text>
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  container: {
    marginTop: 4,
    paddingTop: 8,
    paddingHorizontal: 12,
    paddingBottom: 8,
    backgroundColor: colors.backgroundLight,
    borderRadius: 3,
  },
  text: {
    alignItems: 'flex-start',
    textAlign: 'left',
    color: colors.textDark,
    fontSize: 14,
  },
}))
