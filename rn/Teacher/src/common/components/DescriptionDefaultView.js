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

import React, { PureComponent } from 'react'
import {
  View,
  Text,
  StyleSheet,
} from 'react-native'

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

const styles = StyleSheet.create({
  container: {
    marginTop: 4,
    paddingTop: 8,
    paddingHorizontal: 12,
    paddingBottom: 8,
    backgroundColor: '#F5F5F5',
    borderRadius: 3,
  },
  text: {
    alignItems: 'flex-start',
    textAlign: 'left',
    color: '#73818C',
    fontSize: 14,
  },
})
