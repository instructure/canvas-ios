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

import React from 'react'
import {
  View,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'
import DashboardContent from './DashboardContent'
import {
  Text,
  SubTitle,
} from '../../common/text'

export type GroupRowProps = {
  id: string,
  color: string,
  name: string,
  contextName: string,
  term?: string,
  style?: any,
}

export default class GroupRow extends React.Component<GroupRowProps & { onPress: (string) => void }> {
  navigateToGroup = () => {
    this.props.onPress(this.props.id)
  }

  render () {
    const {
      id,
      name,
      contextName,
      color,
      term,
    } = this.props
    return (
      <TouchableHighlight
        onPress={this.navigateToGroup}
        underlayColor='transparent'
        testID={`group-row-${id}`}
      >
        <View>
          <DashboardContent
            style={this.props.style}
            contentStyle={styles.rowContent}
          >
            <View style={[styles.groupColor, { backgroundColor: color }]} />
            <View style={styles.groupDetails}>
              <Text style={styles.title}>{name}</Text>
              <SubTitle style={[{ color }, styles.context]}>{contextName}</SubTitle>
              {Boolean(term) && <SubTitle style={styles.term}>{term.toUpperCase()}</SubTitle>}
            </View>
          </DashboardContent>
        </View>
      </TouchableHighlight>
    )
  }
}

const styles = StyleSheet.create({
  rowContent: {
    flexDirection: 'row',
    minHeight: 82,
  },
  groupColor: {
    width: 4,
  },
  groupDetails: {
    margin: 8,
  },
  context: {
    fontWeight: '600',
    fontSize: 16,
  },
  title: {
    fontWeight: '600',
    fontSize: 18,
  },
  term: {
    fontSize: 12,
    fontWeight: '600',
  },
})
